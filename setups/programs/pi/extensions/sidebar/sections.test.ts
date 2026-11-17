import { expect, test } from "bun:test";
import { actionAt, panelBackground, type SidebarData, type Style, sidebarContent, sidebarLines } from "./sections";
import type { SubagentNode } from "./subagents";

// Marks styling in plain text, so the tests read what the theme would colour.
const style: Style = {
    fg: (color, text) => `<${color}>${text}</>`,
    bold: (text) => `*${text}*`,
    getBgAnsi: () => "<bg>",
    getColorMode: () => "truecolor",
};

const data = (fields: Partial<SidebarData> = {}): SidebarData => ({
    title: undefined,
    cwd: "/home/me/project",
    home: "/home/me",
    model: "claude-opus-5-5",
    thinking: "high",
    context: undefined,
    skills: [],
    subagents: [],
    folds: new Map(),
    viewed: undefined,
    git: null,
    ...fields,
});

test("a fresh session shows only the header", () => {
    expect(sidebarContent(data(), style, 42).lines).toEqual([
        "",
        "  <dim>~/project</>",
        "  <dim>claude-opus-5-5 · high</>",
    ]);
});

test("every section, in order, a blank row apart", () => {
    const lines = sidebarContent(
        data({
            title: "Sidebar for pi",
            context: { tokens: 45_200, contextWindow: 200_000, percent: 22.6 },
            skills: ["reporting", "tdd"],
            git: {
                head: "main",
                base: "main",
                branch: { files: 0, additions: 0, deletions: 0 },
                dirty: { files: 2, additions: 10, deletions: 3 },
            },
        }),
        style,
        // Wide enough that the test's visible style marks never clip.
        80,
    ).lines;
    expect(lines).toEqual([
        "",
        "  *Sidebar for pi*",
        "  <dim>~/project</>",
        "  <dim>claude-opus-5-5 · high</>",
        "",
        "  *Context*",
        "  <dim>45.2k / 200.0k tokens</>",
        "  <dim>23% used</>",
        "",
        "  *Skills (2)*",
        "  <dim>reporting</>",
        "  <dim>tdd</>",
        "",
        "  *Git*",
        "  <dim>main</>",
        "  <dim>Uncommitted: 2 files</> <toolDiffAdded>+10</> <toolDiffRemoved>-3</>",
    ]);
});

test("context turns to a warning, then an error, as compaction nears", () => {
    const tone = (percent: number) =>
        sidebarContent(data({ context: { tokens: 1, contextWindow: 100, percent } }), style, 42).lines[6];
    expect(tone(70)).toBe("  <dim>70% used</>");
    expect(tone(71)).toBe("  <warning>71% used</>");
    expect(tone(91)).toBe("  <error>91% used</>");
});

test("unknown context after compaction hides the section", () => {
    const lines = sidebarContent(
        data({ context: { tokens: null, contextWindow: 100, percent: null } }),
        style,
        42,
    ).lines;
    expect(lines).not.toContain("  *Context*");
});

test("a long path keeps its leaf, a long model its start", () => {
    const lines = sidebarContent(
        data({ cwd: "/home/me/git/a-rather-long-repository-name", model: "a-model-name-far-too-long-to-fit" }),
        style,
        24,
    ).lines;
    expect(lines[1]).toBe("  <dim>…ong-repository-name</>");
    // The ellipsis carries its own resets.
    expect(Bun.stripANSI(lines[2] ?? "")).toBe("  <dim>a-model-name-far-to…</>");
});

test("the panel fills its full height and width with the background, past the content's resets", () => {
    const lines = sidebarLines(data({ title: "a title that runs past the panel" }), style, 20, 6, "<bg>").lines;
    expect(lines).toHaveLength(6);
    for (const line of lines) {
        expect(line.startsWith("<bg>")).toBe(true);
        expect(line.endsWith("\x1b[49m")).toBe(true);
        expect(Bun.stringWidth(line.replaceAll("<bg>", ""))).toBe(20);
    }
    // The ellipsis resets every attribute; the background comes straight back.
    expect(lines[1]).toContain("\x1b[0m<bg>");
});

/** The RGB a truecolor background escape sets. */
const rgbOf = (sequence: string) =>
    sequence
        .match(/48;2;(\d+);(\d+);(\d+)m/)
        ?.slice(1)
        .map(Number);

const near = (actual: number[] | undefined, expected: number[]) =>
    expect(actual?.every((channel, index) => Math.abs(channel - (expected[index] ?? 0)) <= 5)).toBe(true);

test("the panel is a shade darker than the terminal, as mantle is to base in Catppuccin", () => {
    // mocha base -> mantle #181825, latte base -> mantle #e6e9ef
    near(rgbOf(panelBackground(style, { r: 0x1e, g: 0x1e, b: 0x2e })), [0x18, 0x18, 0x25]);
    near(rgbOf(panelBackground(style, { r: 0xef, g: 0xf1, b: 0xf5 })), [0xe6, 0xe9, 0xef]);
});

test("until the terminal reports its background, the panel takes the theme's custom-message background", () => {
    expect(panelBackground(style, undefined)).toBe("<bg>");
});

const node = (path: string, fields: Partial<SubagentNode> = {}): SubagentNode => ({
    path,
    agent: path,
    task: "",
    tokens: 0,
    state: "done",
    startedAt: 0,
    children: [],
    ...fields,
});

const owner = node("owner", {
    agent: "ticket-owner",
    task: "Ticket owner for #353",
    tokens: 48_100,
    state: "running",
    children: [node("worker", { task: "Implementer for #353", tokens: 130_000, state: "failed" })],
});

test("each subagent shows its agent and tokens, its task under it, nested in the tree", () => {
    const { lines } = sidebarContent(data({ subagents: [owner] }), style, 80);
    const section = lines.slice(lines.indexOf("  *Subagents (2)*"));
    expect(section[1]).toMatch(/^ {2}<dim>└─ <\/><accent>●<\/> ticket-owner +<dim>−<\/> <dim>48\.1k<\/>$/);
    expect(section[2]).toBe("  <dim>   │ </><dim>Ticket owner for #353</>");
    expect(section[3]).toMatch(/^ {2}<dim> {3}└─ <\/><error>✗<\/> <dim>worker<\/> +<warning>130\.0k<\/>$/);
    expect(section[4]).toBe("  <dim>        </><dim>Implementer for #353</>");
});

test("a click on a subagent's rows views it, on its fold mark folds it, and the viewed one leads back", () => {
    const { lines, hits } = sidebarContent(data({ subagents: [owner], viewed: "worker" }), style, 80);
    const top = lines.findIndex((line) => line.includes("*Subagents (2)*"));
    expect(lines[top]).toMatch(/<accent>← Main conversation<\/>$/);
    expect(actionAt(hits, 77, top)).toEqual({ kind: "main" });
    expect(actionAt(hits, 5, top + 1)).toEqual({ kind: "view", path: "owner" });
    expect(actionAt(hits, 5, top + 2)).toEqual({ kind: "view", path: "owner" });
    expect(actionAt(hits, 5, top + 4)).toEqual({ kind: "view", path: "worker" });
    expect(actionAt(hits, lines[top + 1]?.indexOf("<dim>−") ?? -1, top + 1)).toEqual({
        kind: "fold",
        path: "owner",
        open: false,
    });
    // The panel's padding is not part of a row.
    expect(actionAt(hits, 0, top + 1)).toBeUndefined();
    // The viewed subagent stands out, its task undimmed.
    expect(lines[top + 3]).toContain("*<accent>worker</>*");
    expect(lines[top + 4]).toMatch(/<\/>Implementer for #353$/);
});

test("a finished subtree folds into its top row until opened", () => {
    const done = { ...owner, state: "done" as const, children: [node("worker")] };
    const folded = sidebarContent(data({ subagents: [done] }), style, 80);
    expect(folded.lines.filter((line) => line.includes("worker"))).toEqual([]);
    expect(folded.lines.some((line) => line.includes("<dim>+1</>"))).toBe(true);
    const opened = sidebarContent(data({ subagents: [done], folds: new Map([["owner", true]]) }), style, 80);
    expect(opened.lines.some((line) => line.includes("worker"))).toBe(true);
});
