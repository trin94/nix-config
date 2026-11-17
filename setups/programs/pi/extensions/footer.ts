import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

/**
 * Only the statuses other extensions publish, on one row; nothing while there are none. The sidebar
 * extension shows the place, model, context and Git the built-in footer would.
 */
export default function (pi: ExtensionAPI) {
    pi.on("session_start", (_event, ctx) => {
        if (!ctx.hasUI) return;
        // Indented like the editor's text, so both line up.
        const pad = " ".repeat(pi.getSettings().editorPaddingX ?? 0);
        ctx.ui.setFooter((_tui, _theme, footerData) => ({
            invalidate() {},
            render(fullWidth: number): string[] {
                const statuses = [...footerData.getExtensionStatuses().entries()]
                    .sort(([a], [b]) => a.localeCompare(b))
                    .map(([, text]) => text.replace(/\s*\n\s*/g, " "));
                if (statuses.length === 0) return [];
                const width = Math.max(1, fullWidth - pad.length * 2);
                return [pad + truncateToWidth(statuses.join(" "), width, "…")];
            },
        }));
    });
}
