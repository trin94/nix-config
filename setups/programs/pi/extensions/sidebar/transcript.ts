// A subagent's transcript over the chat, opened from its row in the sidebar, as Claude Code shows a subagent's
// conversation in its main view. It follows the child's session file as pi-subagents appends to it and draws the
// messages with Pi's own chat components.

import { open } from "node:fs/promises";
import type { AssistantMessage, ToolResultMessage } from "@earendil-works/pi-ai";
import {
    AssistantMessageComponent,
    createBashToolDefinition,
    createEditToolDefinition,
    createFindToolDefinition,
    createGrepToolDefinition,
    createLsToolDefinition,
    createReadToolDefinition,
    createWriteToolDefinition,
    type ExtensionContext,
    getMarkdownTheme,
    ToolExecutionComponent,
    UserMessageComponent,
} from "@earendil-works/pi-coding-agent";
import {
    type Component,
    Container,
    type KeybindingsManager,
    matchesKey,
    Spacer,
    type TUI,
    type TuiMouseEvent,
    type TuiMouseEventResult,
    truncateToWidth,
    visibleWidth,
} from "@earendil-works/pi-tui";
import { SIDEBAR_COLUMNS, sidebarShown } from "./dock";
import { formatTokens, type Style, stateMark, tokenTone } from "./sections";
import { messageText, type SubagentNode } from "./subagents";

// The sidebar's subagent scan runs every 2 s; the open transcript is worth following more closely.
const POLL_MS = 500;
const BACK = "← Main conversation";
const HINT = "esc close · ctrl+o tools";

/** Hands out the complete lines of a file read in chunks; a line still being written waits for its end. */
export class LineBuffer {
    private partial = "";

    push(chunk: string): string[] {
        const lines = (this.partial + chunk).split("\n");
        this.partial = lines.pop() ?? "";
        return lines.filter((line) => line.trim());
    }
}

/** The first row of a window `height` rows tall on `length` rows, kept in range; at the end while following. */
export function scrollWindow(top: number, length: number, height: number, following: boolean): number {
    const last = Math.max(0, length - height);
    return following ? last : Math.min(Math.max(0, top), last);
}

function isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === "object" && value !== null;
}

function isAssistant(message: Record<string, unknown>): message is Record<string, unknown> & AssistantMessage {
    return message.role === "assistant" && Array.isArray(message.content);
}

function isToolResult(message: Record<string, unknown>): message is Record<string, unknown> & ToolResultMessage {
    return message.role === "toolResult" && typeof message.toolCallId === "string" && Array.isArray(message.content);
}

const BUILT_IN_TOOLS = {
    read: createReadToolDefinition,
    bash: createBashToolDefinition,
    edit: createEditToolDefinition,
    write: createWriteToolDefinition,
    grep: createGrepToolDefinition,
    find: createFindToolDefinition,
    ls: createLsToolDefinition,
};

function isBuiltIn(name: string): name is keyof typeof BUILT_IN_TOOLS {
    return name in BUILT_IN_TOOLS;
}

export type TranscriptOptions = {
    /** The child's session file. */
    path: string;
    /** The child's row in the sidebar's tree, current as of the last scan. */
    describe: () => SubagentNode | undefined;
    hideThinkingBlock: boolean;
    outputPad: number;
};

export class TranscriptView implements Component {
    private readonly body = new Container();
    /** Tool calls still waiting for their result, by call id. */
    private readonly pending = new Map<string, ToolExecutionComponent>();
    private readonly tools: ToolExecutionComponent[] = [];
    private readonly lines = new LineBuffer();
    // A read can end inside a character; the decoder holds its first bytes for the next one.
    private readonly decoder = new TextDecoder();
    private readonly timer: ReturnType<typeof setInterval>;
    private cwd = process.cwd();
    private offset = 0;
    private reading = false;
    private top = 0;
    private following = true;
    private expanded = false;
    /** The body's rows and how many of them showed in the last frame, for scrolling. */
    private length = 0;
    private height = 1;

    constructor(
        private readonly tui: TUI,
        private readonly theme: Style,
        private readonly keybindings: KeybindingsManager,
        private readonly close: () => void,
        private readonly options: TranscriptOptions,
    ) {
        void this.read();
        this.timer = setInterval(() => void this.read(), POLL_MS);
    }

    /** Takes in what pi-subagents appended since the last read. */
    private async read(): Promise<void> {
        if (this.reading) return;
        this.reading = true;
        try {
            const file = await open(this.options.path, "r");
            try {
                const { size } = await file.stat();
                if (size <= this.offset) return;
                const chunk = Buffer.alloc(size - this.offset);
                await file.read(chunk, 0, chunk.length, this.offset);
                this.offset = size;
                for (const line of this.lines.push(this.decoder.decode(chunk, { stream: true }))) this.add(line);
            } finally {
                await file.close();
            }
            this.tui.requestRender();
        } catch {
            // The file is gone or unreadable; keep what was drawn.
        } finally {
            this.reading = false;
        }
    }

    private add(line: string): void {
        let entry: unknown;
        try {
            entry = JSON.parse(line);
        } catch {
            return;
        }
        if (!isRecord(entry)) return;
        if (entry.type === "session" && typeof entry.cwd === "string") this.cwd = entry.cwd;
        if (entry.type !== "message" || !isRecord(entry.message)) return;
        const message = entry.message;
        const { hideThinkingBlock, outputPad } = this.options;
        if (message.role === "user") {
            const text = messageText(message.content);
            if (!text) return;
            if (this.body.children.length > 0) this.body.addChild(new Spacer(1));
            this.body.addChild(new UserMessageComponent(text, getMarkdownTheme(), outputPad));
        } else if (isAssistant(message)) {
            this.body.addChild(
                new AssistantMessageComponent(message, hideThinkingBlock, getMarkdownTheme(), undefined, outputPad),
            );
            for (const content of message.content) {
                if (content.type !== "toolCall") continue;
                const definition = isBuiltIn(content.name) ? BUILT_IN_TOOLS[content.name](this.cwd) : undefined;
                const tool = new ToolExecutionComponent(
                    content.name,
                    content.id,
                    content.arguments,
                    { outputPad },
                    definition,
                    this.tui,
                    this.cwd,
                );
                tool.setExpanded(this.expanded);
                this.tools.push(tool);
                this.body.addChild(tool);
                if (message.stopReason === "aborted" || message.stopReason === "error") {
                    const text = message.errorMessage || (message.stopReason === "aborted" ? "Aborted" : "Error");
                    tool.updateResult({ content: [{ type: "text", text }], isError: true });
                } else {
                    this.pending.set(content.id, tool);
                }
            }
        } else if (isToolResult(message)) {
            this.pending.get(message.toolCallId)?.updateResult(message);
            this.pending.delete(message.toolCallId);
        }
    }

    private header(width: number): string[] {
        const { theme } = this;
        const node = this.options.describe();
        const back = theme.fg("accent", BACK);
        const hint = theme.fg("dim", HINT);
        const gap = width - visibleWidth(back) - visibleWidth(hint);
        const lines = [gap > 0 ? `${back}${" ".repeat(gap)}${hint}` : back];
        if (node) {
            const facts = [
                node.state,
                node.tokens > 0 ? theme.fg(tokenTone(node.tokens), formatTokens(node.tokens)) : "",
            ]
                .filter(Boolean)
                .join(theme.fg("dim", " · "));
            lines.push(`${stateMark(node.state, theme)} ${theme.bold(node.agent)} ${theme.fg("dim", "·")} ${facts}`);
            if (node.task) lines.push(theme.fg("dim", node.task));
        }
        lines.push(theme.fg("borderMuted", "─".repeat(width)));
        return lines;
    }

    render(width: number): string[] {
        const header = this.header(width);
        const body = this.body.render(width);
        this.length = body.length;
        this.height = Math.max(1, this.tui.terminal.rows - header.length);
        this.top = scrollWindow(this.top, body.length, this.height, this.following);
        const window = Array.from({ length: this.height }, (_, row) => body[this.top + row] ?? "");
        return [...header, ...window].map((line) => truncateToWidth(line, width, "…", true));
    }

    private scroll(rows: number): void {
        this.top = Math.max(0, this.top + rows);
        // Reaching the end follows new output again.
        this.following = this.top >= this.length - this.height;
        this.tui.requestRender();
    }

    handleInput(data: string): void {
        const { keybindings } = this;
        if (keybindings.matches(data, "tui.select.cancel")) this.close();
        else if (keybindings.matches(data, "tui.select.up")) this.scroll(-1);
        else if (keybindings.matches(data, "tui.select.down")) this.scroll(1);
        else if (keybindings.matches(data, "tui.select.pageUp")) this.scroll(-this.height);
        else if (keybindings.matches(data, "tui.select.pageDown")) this.scroll(this.height);
        else if (matchesKey(data, "home")) this.scroll(-Number.MAX_SAFE_INTEGER);
        else if (matchesKey(data, "end")) this.scroll(Number.MAX_SAFE_INTEGER);
        else if (keybindings.matches(data, "app.tools.expand")) {
            this.expanded = !this.expanded;
            for (const tool of this.tools) tool.setExpanded(this.expanded);
            this.tui.requestRender();
        }
    }

    handleMouse(event: TuiMouseEvent): TuiMouseEventResult | undefined {
        if (event.type === "wheel") {
            this.scroll(event.wheelDelta ?? 0);
            return { handled: true };
        }
        const onBack = event.y === 0 && event.x < visibleWidth(BACK) && event.button === "left";
        if (!onBack) return;
        if (event.type === "click") this.close();
        return { handled: true };
    }

    invalidate(): void {
        this.body.invalidate();
    }

    dispose(): void {
        clearInterval(this.timer);
    }
}

/**
 * The one transcript open at a time, over the chat and left of the sidebar. Viewing the open one again closes
 * it, as Claude Code's tasks list does.
 */
export function transcriptViewer(describe: (path: string) => SubagentNode | undefined, changed: () => void) {
    let open: { path: string; close: () => void } | undefined;

    const close = () => open?.close();

    return {
        viewed: () => open?.path,
        close,

        toggle(
            path: string,
            ctx: ExtensionContext,
            settings: Pick<TranscriptOptions, "hideThinkingBlock" | "outputPad">,
        ) {
            const same = open?.path === path;
            close();
            if (same) return;
            const current: { path: string; close: () => void } = { path, close: () => {} };
            open = current;
            let screen: TUI | undefined;
            void ctx.ui
                .custom<undefined>(
                    (tui, theme, keybindings, done) => {
                        screen = tui;
                        current.close = () => done(undefined);
                        return new TranscriptView(tui, theme, keybindings, current.close, {
                            path,
                            describe: () => describe(path),
                            ...settings,
                        });
                    },
                    {
                        overlay: true,
                        overlayOptions: () => ({
                            anchor: "top-left",
                            width: "100%",
                            maxHeight: "100%",
                            margin: { right: sidebarShown(screen?.terminal.columns ?? 0) ? SIDEBAR_COLUMNS : 0 },
                        }),
                    },
                )
                .finally(() => {
                    if (open === current) open = undefined;
                    changed();
                });
            changed();
        },
    };
}
