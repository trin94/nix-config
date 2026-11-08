import { homedir } from "node:os";
import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { collectStatus, gitRunner, type StatusSegment, statusSegments } from "./vcs";

const REFRESH_MS = 5000;

function formatTokens(tokens: number): string {
    if (tokens < 1000) return `${tokens}`;
    if (tokens < 1_000_000) return `${(tokens / 1000).toFixed(1)}k`;
    return `${(tokens / 1_000_000).toFixed(2)}M`;
}

/** Tokens and percent of the window, coloured only once compaction is near. */
function contextText(ctx: ExtensionContext, theme: Theme): string {
    const usage = ctx.getContextUsage();
    if (!usage || usage.tokens === null || usage.percent === null) return theme.fg("dim", "context ?");
    const text = `${formatTokens(usage.tokens)} (${Math.round(usage.percent)}%)`;
    if (usage.percent > 90) return theme.fg("error", text);
    if (usage.percent > 70) return theme.fg("warning", text);
    return theme.fg("dim", text);
}

function gitText(segments: readonly StatusSegment[], theme: Theme): string {
    return segments
        .map((segment) => {
            const parts = [theme.fg("dim", segment.label)];
            if (segment.additions > 0) parts.push(theme.fg("toolDiffAdded", `+${segment.additions}`));
            if (segment.deletions > 0) parts.push(theme.fg("toolDiffRemoved", `-${segment.deletions}`));
            return parts.join(" ");
        })
        .join(theme.fg("dim", " · "));
}

/** `left` and `right` on one row, the right side clipped first when they do not fit. */
function spread(left: string, right: string, width: number): string {
    const room = width - visibleWidth(left) - 2;
    if (room <= 0) return truncateToWidth(left, width, "…");
    const clipped = truncateToWidth(right, room, "…");
    return left + " ".repeat(width - visibleWidth(left) - visibleWidth(clipped)) + clipped;
}

/**
 * The footer OpenCode showed: where you are, which model, how full the context is and what changed in Git,
 * then the statuses other extensions publish. Dim throughout; colour marks only diffs and a filling context.
 */
export default function (pi: ExtensionAPI) {
    pi.on("session_start", (_event, ctx) => {
        if (!ctx.hasUI) return;
        // Indented like the editor's text, so both line up.
        const pad = " ".repeat(pi.getSettings().editorPaddingX ?? 0);
        ctx.ui.setFooter((tui, theme, footerData) => {
            const run = gitRunner(ctx.cwd);
            let segments: StatusSegment[] = [];
            let refreshing = false;
            let disposed = false;

            const refresh = async () => {
                if (disposed || refreshing) return;
                refreshing = true;
                try {
                    const status = await collectStatus(run);
                    segments = status ? statusSegments(status) : [];
                } catch {
                    segments = [];
                } finally {
                    refreshing = false;
                }
                if (!disposed) tui.requestRender();
            };

            void refresh();
            const timer = setInterval(() => void refresh(), REFRESH_MS);
            const stopBranchWatch = footerData.onBranchChange(() => void refresh());
            const stopToolWatch = pi.on("tool_execution_end", () => void refresh());

            return {
                dispose() {
                    disposed = true;
                    clearInterval(timer);
                    stopBranchWatch();
                    stopToolWatch();
                },
                invalidate() {},
                render(fullWidth: number): string[] {
                    const width = Math.max(1, fullWidth - pad.length * 2);
                    let place = ctx.cwd.startsWith(homedir()) ? `~${ctx.cwd.slice(homedir().length)}` : ctx.cwd;
                    const branch = footerData.getGitBranch();
                    if (branch) place += ` (${branch})`;
                    const name = ctx.sessionManager.getSessionName();
                    if (name) place += ` • ${name}`;

                    const model = ctx.model;
                    const level = model?.reasoning ? ` • ${pi.getThinkingLevel()}` : "";
                    const modelText = theme.fg("dim", `${model?.id ?? "no model"}${level}`);

                    const usage = [contextText(ctx, theme), gitText(segments, theme)].filter(Boolean);
                    const lines = [
                        spread(theme.fg("dim", place), modelText, width),
                        truncateToWidth(usage.join("   "), width, "…"),
                    ];

                    const statuses = [...footerData.getExtensionStatuses().entries()]
                        .sort(([a], [b]) => a.localeCompare(b))
                        .map(([, text]) => text.replace(/\s*\n\s*/g, " "));
                    if (statuses.length > 0) lines.push(truncateToWidth(statuses.join(" "), width, "…"));
                    return lines.map((line) => pad + line);
                },
            };
        });
    });
}
