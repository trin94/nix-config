import { homedir } from "node:os";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { RgbColor, TUI } from "@earendil-works/pi-tui";
import { Dock } from "./dock";
import { type GitState, panelBackground, sidebarLines } from "./sections";
import { trackSkills } from "./skills";
import { collectStatus, type GitRunner, gitRunner } from "./vcs";

// Git is read from outside Pi; the footer this replaces refreshed as often.
const REFRESH_MS = 5000;
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
 * skills and Git. Fullscreen mode only; the footer keeps just the other extensions' statuses.
 */
export default function (pi: ExtensionAPI) {
    let tui: TUI | undefined;
    let git: GitState | null = null;
    let refreshing = false;
    const redraw = () => tui?.requestRender();
    const skills = trackSkills(pi, redraw);

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
        git,
    });

    pi.on("session_start", (_event, ctx) => {
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
                const dock = new Dock(renderer, {
                    // The panel spans the whole screen, so its background reaches the bottom row.
                    render: (width) =>
                        sidebarLines(
                            data(ctx),
                            theme,
                            width,
                            renderer.terminal.rows,
                            panelBackground(theme, terminalBg),
                        ),
                    invalidate() {},
                });
                void refresh(ctx.cwd);
                const timer = setInterval(() => void refresh(ctx.cwd), REFRESH_MS);
                return {
                    render: (width: number) => dock.render(width),
                    invalidate() {},
                    dispose() {
                        clearInterval(timer);
                        stopSchemeWatch();
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
