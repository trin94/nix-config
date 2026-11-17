import { afterAll, expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { initTheme } from "@earendil-works/pi-coding-agent";
import { KeybindingsManager, type Terminal, TUI_KEYBINDINGS, TuiMainScreen } from "@earendil-works/pi-tui";
import type { Style } from "./sections";
import type { SubagentNode } from "./subagents";
import { LineBuffer, scrollWindow, TranscriptView } from "./transcript";

initTheme("dark");

const style: Style = {
    fg: (color, text) => `<${color}>${text}</>`,
    bold: (text) => `*${text}*`,
    getBgAnsi: () => "<bg>",
    getColorMode: () => "truecolor",
};

/** A screen 80 by 16 that draws nowhere. */
const terminal: Terminal = {
    start() {},
    stop() {},
    async drainInput() {},
    write() {},
    columns: 80,
    rows: 16,
    kittyProtocolActive: false,
    moveBy() {},
    hideCursor() {},
    showCursor() {},
    clearLine() {},
    clearFromCursor() {},
    clearScreen() {},
    setTitle() {},
    setProgress() {},
    setProgramStatus() {},
};

const dir = mkdtempSync(join(tmpdir(), "transcript-"));
afterAll(() => rmSync(dir, { recursive: true }));

const node: SubagentNode = {
    path: "",
    agent: "reviewer",
    task: "Design reviewer",
    tokens: 12_300,
    state: "running",
    startedAt: 0,
    children: [],
};

const entry = (message: unknown) => JSON.stringify({ type: "message", message });

test("a line still being written waits for its end", () => {
    const buffer = new LineBuffer();
    expect(buffer.push('{"a":1}\n{"b"')).toEqual(['{"a":1}']);
    expect(buffer.push(":2}\n")).toEqual(['{"b":2}']);
});

test("the window follows the end until scrolled away, and stays in range", () => {
    expect(scrollWindow(0, 30, 10, true)).toBe(20);
    expect(scrollWindow(5, 30, 10, false)).toBe(5);
    expect(scrollWindow(40, 30, 10, false)).toBe(20);
    expect(scrollWindow(-3, 5, 10, false)).toBe(0);
});

test("a transcript shows the subagent, its task and its messages as they are appended", async () => {
    const path = join(dir, "session.jsonl");
    writeFileSync(
        path,
        [
            JSON.stringify({ type: "session", cwd: dir }),
            entry({ role: "user", content: [{ type: "text", text: "Review the sidebar change" }] }),
            entry({ role: "assistant", content: [{ type: "text", text: "Looks right to me" }], stopReason: "stop" }),
            // Cut off mid-line, as when pi-subagents is still writing.
            '{"type":"mess',
        ].join("\n"),
    );
    let closed = false;
    const view = new TranscriptView(
        new TuiMainScreen(terminal),
        style,
        new KeybindingsManager(TUI_KEYBINDINGS),
        () => (closed = true),
        {
            path,
            describe: () => node,
            hideThinkingBlock: true,
            outputPad: 1,
        },
    );
    try {
        const text = async () => {
            for (let tries = 0; tries < 50; tries++) {
                const lines = view.render(100).map((line) => Bun.stripANSI(line));
                if (lines.some((line) => line.includes("Looks right"))) return lines;
                await Bun.sleep(20);
            }
            return view.render(100).map((line) => Bun.stripANSI(line));
        };
        const lines = await text();
        expect(lines).toHaveLength(16);
        expect(lines[0]).toMatch(/^<accent>← Main conversation<\/> +<dim>esc close · ctrl\+o tools<\/>/);
        expect(lines[1]).toContain("*reviewer*");
        expect(lines[1]).toContain("12.3k");
        expect(lines[2]).toContain("Design reviewer");
        expect(lines.join("\n")).toContain("Review the sidebar change");
        expect(lines.join("\n")).toContain("Looks right to me");

        view.handleInput("\x1b");
        expect(closed).toBe(true);
        closed = false;
        const click = { button: "left", x: 2, y: 0, screenX: 2, screenY: 0, width: 100, height: 16 } as const;
        const at = { ...click, shift: false, alt: false, ctrl: false };
        expect(view.handleMouse({ ...at, type: "press" })).toEqual({ handled: true });
        view.handleMouse({ ...at, type: "click" });
        expect(closed).toBe(true);
    } finally {
        view.dispose();
    }
});
