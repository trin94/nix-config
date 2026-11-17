// The Subagents tree: every subagent this session launched, nested under the one that launched it, as in the
// Claude Code sidebar. Pure; feed.ts reads the session files and pi-subagents' status, sections.ts draws it.

/** What the start of a child session file says, which never changes once its task is written. */
export type SubagentHead = {
    /** The session file that launched it, from the header pi-subagents writes. */
    parent: string | null;
    agent: string;
    startedAt: number;
    /** The task's opening, empty until the first user message is in the file. */
    task: string;
};

/** What one child session file says about its agent. */
export type SubagentSession = SubagentHead & {
    path: string;
    /** Context size at its last response. */
    tokens: number;
    /** `open` until its last response ends the turn. */
    outcome: "open" | "done" | "failed";
};

export type SubagentState = "running" | "done" | "failed";

export type SubagentNode = {
    /** The child's session file, which identifies it. */
    path: string;
    agent: string;
    task: string;
    tokens: number;
    state: SubagentState;
    startedAt: number;
    children: SubagentNode[];
};

export type SubagentRow = {
    node: SubagentNode;
    /** Tree lines before the row's mark. */
    prefix: string;
    /** Tree lines under `prefix`, for the row's second line. */
    continuation: string;
    /** Descendants folded into this row. */
    hidden: number;
    /** Its children are drawn below it. */
    expanded: boolean;
};

/** Per session file, whether its subtree is open; a subtree without an override is open while busy. */
export type Folds = ReadonlyMap<string, boolean>;

// pi-subagents names each child session `subagent-<agent>-<id>-<n>`.
const SESSION_NAME = /^subagent-(.+)-[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}-\d+$/;

function isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === "object" && value !== null;
}

function parseLines(text: string): Record<string, unknown>[] {
    return text.split("\n").flatMap((line) => {
        try {
            const value: unknown = JSON.parse(line);
            return isRecord(value) ? [value] : [];
        } catch {
            return [];
        }
    });
}

function record(value: unknown): Record<string, unknown> | undefined {
    return isRecord(value) ? value : undefined;
}

/** The text of a message's content, a string or a list of parts. */
export function messageText(content: unknown): string {
    if (typeof content === "string") return content;
    if (!Array.isArray(content)) return "";
    return content
        .map((part) => (isRecord(part) && part.type === "text" && typeof part.text === "string" ? part.text : ""))
        .join("");
}

/**
 * A task's first line, without the boilerplate every brief opens with: "Task: You are the Design reviewer.
 * Repo…" reads "Design reviewer. Repo…".
 */
export function taskLabel(task: string): string {
    const line = task.split("\n").find((text) => text.trim()) ?? "";
    const label = line
        .replace(/^\s*Task:\s*/i, "")
        .replace(/^You are (?:the |a |an )?/i, "")
        .replace(/\s+/g, " ")
        .trim();
    return label.charAt(0).toUpperCase() + label.slice(1);
}

/** A child session's header, name and task from the start of its file. A line cut off at the end is skipped. */
export function readHead(head: string): SubagentHead | undefined {
    const entries = parseLines(head);
    const header = entries.find((entry) => entry.type === "session");
    if (!header) return;
    const parent = header.parentSession;
    const name = entries.find((entry) => entry.type === "session_info")?.name;
    const timestamp = Date.parse(String(header.timestamp));
    const task = entries.map((entry) => record(entry.message)).find((message) => message?.role === "user");
    return {
        parent: typeof parent === "string" ? parent : null,
        agent: (typeof name === "string" && SESSION_NAME.exec(name)?.[1]) || "subagent",
        startedAt: Number.isNaN(timestamp) ? 0 : timestamp,
        task: task ? taskLabel(messageText(task.content)) : "",
    };
}

/** One child session from its head and the end of its file (last response). A line cut off at the start is skipped. */
export function summarize(path: string, head: SubagentHead, tail: string): SubagentSession {
    const replies = parseLines(tail)
        .map((entry) => record(entry.message))
        .filter((message) => message?.role === "assistant");
    const last = replies.at(-1);
    const usage = record(last?.usage);
    const tokens = typeof usage?.totalTokens === "number" ? usage.totalTokens : 0;
    const stop = last?.stopReason;
    const outcome = stop === "stop" ? "done" : stop === "error" || stop === "aborted" ? "failed" : "open";
    return { ...head, path, tokens, outcome };
}

/**
 * The sessions under `main` as a tree. An open session is running while its top-level run is live; once that
 * run has ended, it was cut off.
 */
export function subagentTree(
    sessions: readonly SubagentSession[],
    main: string,
    isLive: (session: SubagentSession) => boolean,
): SubagentNode[] {
    const children = new Map<string, SubagentSession[]>();
    for (const session of sessions) {
        if (!session.parent) continue;
        children.set(session.parent, [...(children.get(session.parent) ?? []), session]);
    }
    const build = (parent: string, seen: Set<string>, root?: SubagentSession): SubagentNode[] =>
        (children.get(parent) ?? [])
            .filter((session) => !seen.has(session.path))
            .toSorted((a, b) => a.startedAt - b.startedAt)
            .map((session) => {
                const top = root ?? session;
                const state: SubagentState =
                    session.outcome === "open" ? (isLive(top) ? "running" : "failed") : session.outcome;
                return {
                    path: session.path,
                    agent: session.agent,
                    task: session.task,
                    tokens: session.tokens,
                    state,
                    startedAt: session.startedAt,
                    children: build(session.path, new Set([...seen, session.path]), top),
                };
            });
    return build(main, new Set());
}

export function descendants(node: SubagentNode): number {
    return node.children.reduce((sum, child) => sum + 1 + descendants(child), 0);
}

/** The node for session file `path`, at any depth. */
export function findNode(nodes: readonly SubagentNode[], path: string): SubagentNode | undefined {
    for (const node of nodes) {
        if (node.path === path) return node;
        const found = findNode(node.children, path);
        if (found) return found;
    }
}

function busy(node: SubagentNode): boolean {
    return node.state === "running" || node.children.some(busy);
}

/**
 * Depth-first with tree-drawing prefixes. A subtree folds into its top row while nothing in it runs, unless
 * `folds` says otherwise.
 */
export function subagentRows(nodes: readonly SubagentNode[], folds: Folds, indent = ""): SubagentRow[] {
    return nodes.flatMap((node, index) => {
        const last = index === nodes.length - 1;
        const prefix = indent + (last ? "└─ " : "├─ ");
        const continuation = indent + (last ? "   " : "│  ");
        if (node.children.length === 0) return [{ node, prefix, continuation, hidden: 0, expanded: false }];
        const expanded = folds.get(node.path) ?? busy(node);
        if (!expanded) return [{ node, prefix, continuation, hidden: descendants(node), expanded }];
        return [
            { node, prefix, continuation, hidden: 0, expanded },
            ...subagentRows(node.children, folds, continuation),
        ];
    });
}
