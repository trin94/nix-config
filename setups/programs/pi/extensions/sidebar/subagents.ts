// The Subagents tree: every subagent this session launched, nested under the one that launched it, as in the
// Claude Code sidebar. Pure; feed.ts reads the session files and pi-subagents' status, sections.ts draws it.

/** What one child session file says about its agent. */
export type SubagentSession = {
    path: string;
    /** The session file that launched it, from the header pi-subagents writes. */
    parent: string | null;
    agent: string;
    startedAt: number;
    /** Context size at its last response. */
    tokens: number;
    /** `open` until its last response ends the turn. */
    outcome: "open" | "done" | "failed";
};

export type SubagentState = "running" | "done" | "failed";

export type SubagentNode = {
    agent: string;
    tokens: number;
    state: SubagentState;
    startedAt: number;
    children: SubagentNode[];
};

export type SubagentRow = {
    prefix: string;
    agent: string;
    tokens: number;
    state: SubagentState;
    /** Descendants folded into this row. */
    hidden: number;
};

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

/**
 * One child session from the start of its file (header and name) and its end (last response). Lines cut off
 * at either edge are skipped.
 */
export function summarize(path: string, head: string, tail: string): SubagentSession | undefined {
    const start = parseLines(head);
    const header = start.find((entry) => entry.type === "session");
    if (!header) return;
    const parent = header.parentSession;
    const name = start.find((entry) => entry.type === "session_info")?.name;
    const agent = (typeof name === "string" && SESSION_NAME.exec(name)?.[1]) || "subagent";
    const timestamp = Date.parse(String(header.timestamp));

    const replies = parseLines(tail)
        .map((entry) => record(entry.message))
        .filter((message) => message?.role === "assistant");
    const last = replies.at(-1);
    const usage = record(last?.usage);
    const tokens = typeof usage?.totalTokens === "number" ? usage.totalTokens : 0;
    const stop = last?.stopReason;
    const outcome = stop === "stop" ? "done" : stop === "error" || stop === "aborted" ? "failed" : "open";

    return {
        path,
        parent: typeof parent === "string" ? parent : null,
        agent,
        startedAt: Number.isNaN(timestamp) ? 0 : timestamp,
        tokens,
        outcome,
    };
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
                    agent: session.agent,
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

function busy(node: SubagentNode): boolean {
    return node.state === "running" || node.children.some(busy);
}

/** Depth-first with tree-drawing prefixes; a subtree with nothing running folds into its top row. */
export function subagentRows(nodes: readonly SubagentNode[], indent = ""): SubagentRow[] {
    return nodes.flatMap((node, index) => {
        const last = index === nodes.length - 1;
        const prefix = indent + (last ? "└─ " : "├─ ");
        const row = { prefix, agent: node.agent, tokens: node.tokens, state: node.state };
        if (node.children.length > 0 && !busy(node)) return [{ ...row, hidden: descendants(node) }];
        return [{ ...row, hidden: 0 }, ...subagentRows(node.children, indent + (last ? "   " : "│  "))];
    });
}
