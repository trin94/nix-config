import type { ExtensionAPI, ExtensionContext, ExtensionEvent, Skill, Theme } from "@earendil-works/pi-coding-agent";
import { collectStatus, type Stats, type VcsStatus } from "../../opencode/vcs-status/vcs.ts";
import { loadedSkills } from "./skills.ts";

const BRANCH_STATUS = "dotfiles-git-branch-diff";
const DIRTY_STATUS = "dotfiles-git-dirty";
const SKILLS_STATUS = "dotfiles-loaded-skills";
const REFRESH_MS = 5000;

function statistics(stats: Stats, theme: Theme): string {
    return `${stats.files} ${stats.files === 1 ? "file" : "files"} ${theme.fg("toolDiffAdded", `+${stats.additions}`)} ${theme.fg("toolDiffRemoved", `-${stats.deletions}`)}`;
}

export type StatusContext = Pick<ExtensionContext, "cwd" | "mode" | "sessionManager"> & {
    ui: Pick<ExtensionContext["ui"], "theme" | "setStatus">;
};

export type StatusEvent = Extract<
    ExtensionEvent,
    {
        type:
            | "session_start"
            | "before_agent_start"
            | "message_end"
            | "tool_execution_end"
            | "agent_end"
            | "session_tree"
            | "session_compact"
            | "session_shutdown";
    }
>;

export type StatusAPI = Pick<ExtensionAPI, "exec" | "getCommands"> & {
    on<K extends StatusEvent["type"]>(
        name: K,
        handler: (event: Extract<StatusEvent, { type: K }>, ctx: StatusContext) => void,
    ): void;
};

/** Supplemental data for pi-footer; does not replace the footer/editor or change model context. */
export default function sessionStatus(pi: ExtensionAPI): void {
    registerSessionStatus(pi);
}

export function registerSessionStatus(pi: StatusAPI): void {
    let stop: (() => void) | undefined;
    let refreshGit: (() => Promise<void>) | undefined;
    let refreshSkills: (() => void) | undefined;
    let catalog: Pick<Skill, "name" | "filePath">[] = [];

    pi.on("session_start", (_event, ctx) => {
        stop?.();
        if (ctx.mode !== "tui") return;
        catalog = pi
            .getCommands()
            .filter((command) => command.source === "skill")
            .map((command) => ({ name: command.name.replace(/^skill:/, ""), filePath: command.sourceInfo.path }));
        const controller = new AbortController();
        let disposed = false;
        let busy = false;
        let queued = false;
        let status: VcsStatus | undefined;

        const publishGit = () => {
            const theme = ctx.ui.theme;
            ctx.ui.setStatus(
                BRANCH_STATUS,
                theme.fg(
                    "dim",
                    status ? `Since ${status.base}: ${statistics(status.branch, theme)}` : "Git: no repository",
                ),
            );
            ctx.ui.setStatus(
                DIRTY_STATUS,
                theme.fg("dim", status ? `Uncommitted: ${statistics(status.dirty, theme)}` : "Uncommitted: —"),
            );
        };
        ctx.ui.setStatus(BRANCH_STATUS, ctx.ui.theme.fg("dim", "Git: loading…"));
        ctx.ui.setStatus(DIRTY_STATUS, ctx.ui.theme.fg("dim", "Uncommitted: loading…"));
        refreshGit = async () => {
            if (disposed) return;
            if (busy) {
                queued = true;
                return;
            }
            busy = true;
            try {
                do {
                    queued = false;
                    status = await collectStatus(async (args) => {
                        const result = await pi.exec("git", ["--no-optional-locks", ...args], {
                            cwd: ctx.cwd,
                            timeout: 1500,
                            signal: controller.signal,
                        });
                        return result.code === 0 && !result.killed ? result.stdout.trim() : undefined;
                    });
                    if (!disposed) publishGit();
                } while (queued && !disposed);
            } catch {
                if (!disposed) {
                    ctx.ui.setStatus(BRANCH_STATUS, ctx.ui.theme.fg("dim", "Git: unavailable"));
                    ctx.ui.setStatus(DIRTY_STATUS, ctx.ui.theme.fg("dim", "Uncommitted: unavailable"));
                }
            } finally {
                busy = false;
            }
        };
        refreshSkills = () => {
            if (disposed) return;
            const skills = loadedSkills(ctx.sessionManager.getBranch(), catalog, ctx.cwd);
            ctx.ui.setStatus(
                SKILLS_STATUS,
                `Skills (${skills.length}): ${skills.length ? skills.join(" · ") : "none loaded"}`,
            );
        };
        refreshSkills();
        void refreshGit();
        const timer = setInterval(() => void refreshGit?.(), REFRESH_MS);
        timer.unref();
        stop = () => {
            disposed = true;
            controller.abort();
            clearInterval(timer);
            ctx.ui.setStatus(BRANCH_STATUS, undefined);
            ctx.ui.setStatus(DIRTY_STATUS, undefined);
            ctx.ui.setStatus(SKILLS_STATUS, undefined);
            refreshGit = undefined;
            refreshSkills = undefined;
        };
    });

    pi.on("before_agent_start", (event) => {
        catalog = event.systemPromptOptions.skills ?? [];
        refreshSkills?.();
    });
    pi.on("message_end", (event) => {
        if (
            event.message.role === "user" ||
            (event.message.role === "toolResult" && event.message.toolName === "read")
        ) {
            refreshSkills?.();
        }
    });
    pi.on("tool_execution_end", (event) => {
        if (["bash", "write", "edit"].includes(event.toolName)) void refreshGit?.();
    });
    const refresh = () => {
        refreshSkills?.();
        void refreshGit?.();
    };
    pi.on("agent_end", refresh);
    pi.on("session_tree", refresh);
    pi.on("session_compact", refresh);
    pi.on("session_shutdown", () => {
        stop?.();
        stop = undefined;
    });
}
