// Seats a component to the right of Pi's fullscreen layout, the way the Claude Code dock does: Pi's layout
// root goes unchanged into the left cell of an HStack, so the chat narrows instead of being covered.

import { type Component, HStack, isViewportTUI, type TUI, type ViewportTUI } from "@earendil-works/pi-tui";

/** OpenCode's sidebar width. */
export const SIDEBAR_COLUMNS = 42;
/** Below this many columns left for the chat, the sidebar steps aside. */
const MIN_MAIN_COLUMNS = 80;

// Shared across module copies, so a root an earlier runtime (a reload, a session switch) left mounted is still
// recognised and unwrapped instead of nested.
const BASE = Symbol.for("dotfiles/pi-sidebar:base");

class DockRoot extends HStack {
    readonly [BASE]: Component;

    constructor(base: Component, panel: Component) {
        super([
            { component: base, basis: 0, grow: 1 },
            {
                component: panel,
                basis: SIDEBAR_COLUMNS,
                shrink: 0,
                visible: (viewport) => viewport.width >= SIDEBAR_COLUMNS + MIN_MAIN_COLUMNS,
            },
        ]);
        this[BASE] = base;
    }
}

function isComponent(value: unknown): value is Component {
    return typeof value === "object" && value !== null && "render" in value && typeof value.render === "function";
}

/**
 * pi-tui 1.5.2 sets the layout root publicly but keeps it private; this is the one private read. Pi also
 * puts its own root back when it returns to fullscreen, which the next frame then wraps again.
 */
function layoutRoot(tui: ViewportTUI): Component | undefined {
    const root: unknown = Reflect.get(tui, "layoutRoot");
    return isComponent(root) ? root : undefined;
}

/** Pi's own layout, under any sidebar an earlier runtime mounted. */
function baseOf(root: Component): Component {
    const base: unknown = Reflect.get(root, BASE);
    return isComponent(base) ? base : root;
}

/**
 * A zero-line widget: its factory hands over Pi's renderer, and as Pi draws it every frame it notices when
 * Pi has replaced the root and docks the panel again. Regular mode has no layout root and no sidebar.
 */
export class Dock implements Component {
    private mounted: DockRoot | undefined;
    private queued = false;

    constructor(
        private readonly tui: TUI,
        private readonly panel: Component,
    ) {}

    render(_width: number): string[] {
        const tui = this.viewport();
        if (tui && !this.queued && layoutRoot(tui) !== this.mounted) {
            // Never swap the root in the middle of Pi's frame.
            this.queued = true;
            queueMicrotask(() => {
                this.queued = false;
                this.mount();
            });
        }
        return [];
    }

    invalidate(): void {}

    dispose(): void {
        const tui = this.viewport();
        if (tui && this.mounted && layoutRoot(tui) === this.mounted) tui.setLayoutRoot(this.mounted[BASE]);
        this.mounted = undefined;
    }

    private viewport(): ViewportTUI | undefined {
        return isViewportTUI(this.tui) && this.tui.mode === "fullscreen" ? this.tui : undefined;
    }

    private mount(): void {
        const tui = this.viewport();
        const root = tui && layoutRoot(tui);
        if (!tui || !root || root === this.mounted) return;
        this.mounted = new DockRoot(baseOf(root), this.panel);
        tui.setLayoutRoot(this.mounted);
    }
}
