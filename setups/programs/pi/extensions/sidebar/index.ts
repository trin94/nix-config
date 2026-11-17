import { homedir } from "node:os";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { Component, RgbColor, TUI } from "@earendil-works/pi-tui";
import { Dock } from "./dock";
import { subagentFeed } from "./feed";
import { actionAt, type GitState, type Hit, panelBackground, type SidebarAction, sidebarLines } from "./sections";
import { trackSkills } from "./skills";
import { findNode } from "./subagents";
import { transcriptViewer } from "./transcript";
import { collectStatus, type GitRunner, gitRunner } from "./vcs";

// Git is read from outside Pi; the footer this replaces refreshed as often.
const REFRESH_MS = 5000;
// Subagents' token counts grow without an event; the Claude Code sidebar redraws as often.
const SUBAGENT_MS = 2000;
// As long as Pi waits for its own colour query; a later reply still lands through onLateReply.
const COLOR_QUERY_MS = 100;

async function collectGit(run: GitRunner): Promise<GitState | null> {
    const status = await collectStatus(run);
    if (!status) return null;
    const head = (await run(["branch", "--show-current"])) || (await run(["rev-parse", "--short", "HEAD"]));
    return { ...status, head: head ?? "no commits" };
}

/**
 * A permanent sidebar beside the chat, as in the Claude Code and OpenCode setups: session, context, loaded
 * skills, subagents and Git. Fullscreen mode only; the footer keeps just the other extensions' statuses.
 */
export default function (pi: ExtensionAPI) {
    let tui: TUI | undefined;
    let git: GitState | null = null;
    let refreshing = false;
    const redraw = () => tui?.requestRender();
    const skills = trackSkills(pi, redraw);
    const subagents = subagentFeed(pi, redraw);
    const viewer = transcriptViewer((path) => findNode(subagents.nodes(), path), redraw);
    // Subtrees the person opened or folded, until the session changes.
    const folds = new Map<string, boolean>();

    const act = (action: SidebarAction, ctx: ExtensionContext) => {
        if (action.kind === "main") viewer.close();
        else if (action.kind === "fold") folds.set(action.path, action.open);
        else {
            const settings = pi.getSettings();
            viewer.toggle(action.path, ctx, {
                hideThinkingBlock: settings.hideThinkingBlock ?? false,
                outputPad: settings.outputPad ?? 1,
            });
        }
        redraw();
    };

    // Tool calls and the timer overlap; one git pass at a time is enough.
    const refresh = async (cwd: string) => {
        if (refreshing) return;
        refreshing = true;
        try {
            git = await collectGit(gitRunner(cwd));
        } catch {
            git = null;
        } finally {
            refreshing = false;
        }
        redraw();
    };

    const data = (ctx: ExtensionContext) => ({
        title: ctx.sessionManager.getSessionName(),
        cwd: ctx.cwd,
        home: homedir(),
        model: ctx.model?.id,
        thinking: ctx.model?.reasoning ? pi.getThinkingLevel() : undefined,
        context: ctx.getContextUsage(),
        skills: skills(),
        subagents: subagents.nodes(),
        folds,
        viewed: viewer.viewed(),
        git,
    });

    pi.on("session_start", (_event, ctx) => {
        folds.clear();
        viewer.close();
        if (!ctx.hasUI) return;
        ctx.ui.setWidget(
            "sidebar",
            (renderer, theme) => {
                tui = renderer;
                // The panel is shaded from the terminal's own background, asked again when it turns light or dark.
                let terminalBg: RgbColor | undefined;
                const learn = (colors: { background?: RgbColor }) => {
                    if (!colors.background) return;
                    terminalBg = colors.background;
                    redraw();
                };
                const askColors = () =>
                    void renderer.queryTerminalColors({ timeoutMs: COLOR_QUERY_MS, onLateReply: learn }).then(learn);
                askColors();
                const stopSchemeWatch = renderer.onTerminalColorSchemeChange(askColors);
                // Where the last frame put each clickable span.
                let hits: readonly Hit[] = [];
                const panel: Component = {
                    // The panel spans the whole screen, so its background reaches the bottom row.
                    render(width) {
                        const bg = panelBackground(theme, terminalBg);
                        const drawn = sidebarLines(data(ctx), theme, width, renderer.terminal.rows, bg);
                        hits = drawn.hits;
                        return drawn.lines;
                    },
                    // Claiming the press makes the release a click on the panel; elsewhere text selection keeps it.
                    handleMouse(event) {
                        const action = event.button === "left" ? actionAt(hits, event.x, event.y) : undefined;
                        if (!action) return;
                        if (event.type === "click") act(action, ctx);
                        return { handled: true };
                    },
                    invalidate() {},
                };
                const dock = new Dock(renderer, panel);
                void refresh(ctx.cwd);
                const timer = setInterval(() => void refresh(ctx.cwd), REFRESH_MS);
                const scan = () => void subagents.refresh(ctx.sessionManager.getSessionFile());
                scan();
                const subagentTimer = setInterval(scan, SUBAGENT_MS);
                return {
                    render: (width: number) => dock.render(width),
                    invalidate() {},
                    dispose() {
                        clearInterval(timer);
                        clearInterval(subagentTimer);
                        stopSchemeWatch();
                        viewer.close();
                        dock.dispose();
                        tui = undefined;
                    },
                };
            },
            // Below the editor Pi adds no spacer around a widget, so the zero-line dock leaves no gap.
            { placement: "belowEditor" },
        );
    });

    // Edits and commits land through tool calls; catch them before the next tick.
    pi.on("tool_execution_end", (_event, ctx) => void refresh(ctx.cwd));
    pi.on("message_end", redraw);
    pi.on("session_compact", redraw);
    pi.on("session_info_changed", redraw);
    pi.on("model_select", redraw);
    pi.on("thinking_level_select", redraw);
}
