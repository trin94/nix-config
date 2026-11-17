// What the sidebar draws, top to bottom: header, context, skills and Git, laid out like the Claude Code and
// OpenCode sidebars, on a darker panel as in OpenCode. Pure, so the tests can draw it without Pi.

import type { ContextUsage, Theme } from "@earendil-works/pi-coding-agent";
import {
    backgroundAnsi,
    colorToOklch,
    oklchColor,
    type RgbColor,
    rgbColor,
    truncateToWidth,
    visibleWidth,
} from "@earendil-works/pi-tui";
import { statusSegments, type VcsStatus } from "./vcs";

export type Style = Pick<Theme, "fg" | "bold" | "getBgAnsi" | "getColorMode">;

/**
 * How much darker the panel is than the terminal, in OKLCH lightness: Catppuccin's step from base to mantle,
 * which OpenCode's sidebar sits on, is 0.024 to 0.032 in every flavour, light or dark.
 */
const PANEL_DARKER = 0.03;

/** A full reset, as the ellipsis and some themes emit it; it would drop the panel colour for the rest of a row. */
const RESET = "\x1b[0m";
const DEFAULT_BG = "\x1b[49m";

export type GitState = VcsStatus & {
    /** The branch, or the short commit when detached. */
    head: string;
};

export type SidebarData = {
    title: string | undefined;
    cwd: string;
    home: string;
    model: string | undefined;
    /** Left out on models that take no thinking level. */
    thinking: string | undefined;
    context: ContextUsage | undefined;
    skills: readonly string[];
    /** Null outside a repository. */
    git: GitState | null;
};

/** `~` for the home directory. */
export function homeRelative(path: string, home: string): string {
    if (path === home) return "~";
    return path.startsWith(`${home}/`) ? `~${path.slice(home.length)}` : path;
}

export function formatTokens(tokens: number): string {
    if (tokens < 1000) return `${tokens}`;
    if (tokens < 1_000_000) return `${(tokens / 1000).toFixed(1)}k`;
    return `${(tokens / 1_000_000).toFixed(2)}M`;
}

/** Keeps the end of `text`, where a path's leaf is. */
function clipStart(text: string, width: number): string {
    if (visibleWidth(text) <= width) return text;
    let tail = text;
    while (tail.length > 0 && visibleWidth(tail) > width - 1) tail = tail.slice(1);
    return `…${tail}`;
}

function clipEnd(text: string, width: number): string {
    return truncateToWidth(text, width, "…");
}

function header(data: SidebarData, style: Style, width: number): string[] {
    const lines: string[] = [];
    if (data.title) lines.push(style.bold(clipEnd(data.title, width)));
    lines.push(style.fg("dim", clipStart(homeRelative(data.cwd, data.home), width)));
    const model = [data.model ?? "no model", data.thinking].filter(Boolean).join(" · ");
    lines.push(style.fg("dim", clipEnd(model, width)));
    return lines;
}

/** Hidden until a response says how full the window is; coloured only once compaction is near. */
function context(usage: ContextUsage | undefined, style: Style, width: number): string[] {
    if (!usage || usage.tokens === null || usage.percent === null) return [];
    const tone = usage.percent > 90 ? "error" : usage.percent > 70 ? "warning" : "dim";
    return [
        style.bold("Context"),
        style.fg(tone, clipEnd(`${formatTokens(usage.tokens)} / ${formatTokens(usage.contextWindow)} tokens`, width)),
        style.fg(tone, `${Math.round(usage.percent)}% used`),
    ];
}

function skills(names: readonly string[], style: Style, width: number): string[] {
    if (names.length === 0) return [];
    return [style.bold(`Skills (${names.length})`), ...names.map((name) => style.fg("dim", clipEnd(name, width)))];
}

function git(state: GitState | null, style: Style, width: number): string[] {
    if (!state) return [];
    const segments = statusSegments(state).map((segment) => {
        const parts = [style.fg("dim", segment.label)];
        if (segment.additions > 0) parts.push(style.fg("toolDiffAdded", `+${segment.additions}`));
        if (segment.deletions > 0) parts.push(style.fg("toolDiffRemoved", `-${segment.deletions}`));
        return clipEnd(parts.join(" "), width);
    });
    return [style.bold("Git"), style.fg("dim", clipEnd(state.head, width)), ...segments];
}

/** Columns of padding on each side, as in OpenCode's sidebar. */
const PADDING_X = 2;

/** Padding on each side, a blank row on top and between sections. */
export function sidebarContent(data: SidebarData, style: Style, width: number): string[] {
    const inner = Math.max(1, width - PADDING_X * 2);
    const pad = " ".repeat(PADDING_X);
    const sections = [
        header(data, style, inner),
        context(data.context, style, inner),
        skills(data.skills, style, inner),
        git(data.git, style, inner),
    ].filter((lines) => lines.length > 0);
    const lines = [""];
    for (const [index, section] of sections.entries()) {
        if (index > 0) lines.push("");
        lines.push(...section.map((line) => `${pad}${line}`));
    }
    return lines;
}

/**
 * A shade darker than the terminal's background, as OpenCode's panel is to its page. Before the terminal reports
 * its background, or when it never does, the theme's custom-message background, which at least sets the panel
 * apart; pi-claude-code-ui blanks the user-message and tool backgrounds.
 */
export function panelBackground(style: Style, terminal: RgbColor | undefined): string {
    if (!terminal) return style.getBgAnsi("customMessageBg");
    const { l, c, h } = colorToOklch(rgbColor(terminal.r, terminal.g, terminal.b));
    return backgroundAnsi(oklchColor(Math.max(0, l - PANEL_DARKER), c, h), style.getColorMode());
}

/** The content on a panel `height` rows tall, every row padded to `width`, in the `bg` escape. */
export function sidebarLines(data: SidebarData, style: Style, width: number, height: number, bg: string): string[] {
    const content = sidebarContent(data, style, width);
    const rows = Array.from({ length: Math.max(height, content.length) }, (_, row) => content[row] ?? "");
    return rows.map((line) => {
        const padded = truncateToWidth(line, width, "", true);
        return `${bg}${padded.replaceAll(RESET, `${RESET}${bg}`)}${DEFAULT_BG}`;
    });
}
