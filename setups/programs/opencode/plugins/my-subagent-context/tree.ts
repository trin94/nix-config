// The Subagents section's model, pure so the tests run without OpenCode.

import type { ModelInfo, SessionInfo, SessionMessageInfo } from "@opencode/client";

/** What the tree needs of a session. */
export type Node = Pick<SessionInfo, "id" | "parentID"> & { time: Pick<SessionInfo["time"], "created"> };

export interface Row<S extends Node = SessionInfo> {
    session: S;
    prefix: string;
    /** Descendants folded away under this row. */
    hidden: number;
    expanded: boolean;
    hasChildren: boolean;
}

export type State = "running" | "done" | "failed";

/**
 * Descendants of `rootID` in depth-first order, with tree-drawing prefixes, and how many there are.
 * A subtree with no open session folds into its top row unless `overrides` says otherwise.
 */
export function tree<S extends Node>(
    sessions: readonly S[],
    rootID: string,
    open: (sessionID: string) => boolean,
    overrides: Readonly<Record<string, boolean>>,
): { rows: Row<S>[]; total: number } {
    const children = new Map<string, S[]>();
    for (const session of sessions) {
        if (!session.parentID) continue;
        children.set(session.parentID, [...(children.get(session.parentID) ?? []), session]);
    }
    const descendants = (sessionID: string): S[] =>
        (children.get(sessionID) ?? []).flatMap((child) => [child, ...descendants(child.id)]);

    const walk = (parentID: string, indent: string): Row<S>[] => {
        const group = (children.get(parentID) ?? []).toSorted((a, b) => a.time.created - b.time.created);
        return group.flatMap((session, index) => {
            const last = index === group.length - 1;
            const prefix = indent + (last ? "└─ " : "├─ ");
            const hidden = descendants(session.id);
            const hasChildren = hidden.length > 0;
            const expanded = overrides[session.id] ?? [session, ...hidden].some((member) => open(member.id));
            if (hasChildren && !expanded) {
                return [{ session, prefix, hidden: hidden.length, expanded, hasChildren }];
            }
            return [
                { session, prefix, hidden: 0, expanded, hasChildren },
                ...walk(session.id, indent + (last ? "   " : "│  ")),
            ];
        });
    };
    return { rows: walk(rootID, ""), total: descendants(rootID).length };
}

/** A session that is not running failed when its last run did not succeed. */
export function state(session: Pick<SessionInfo, "outcome">, running: boolean): State {
    if (running) return "running";
    return session.outcome === "failed" || session.outcome === "interrupted" ? "failed" : "done";
}

/** `+N` opens a folded subtree, `−` folds an open one; a row without children has neither. */
export function foldText(row: Pick<Row<Node>, "hasChildren" | "expanded" | "hidden">): string | undefined {
    if (!row.hasChildren) return;
    return row.expanded ? "−" : `+${row.hidden}`;
}

/** Tokens of the last assistant step since the latest compaction, as in OpenCode's prompt footer. */
export function contextUsage(messages: readonly SessionMessageInfo[], models: readonly ModelInfo[], boundary?: string) {
    const boundaryIndex = boundary ? messages.findIndex((message) => message.id === boundary) : -1;
    const end = boundaryIndex === -1 ? messages.length : boundaryIndex;
    const compaction = messages.findLastIndex(
        (message, index) => message.type === "compaction" && message.status === "completed" && index < end,
    );
    const last = messages.findLast(
        (message, index) => message.type === "assistant" && message.tokens && index > compaction && index < end,
    );
    if (last?.type !== "assistant" || !last.tokens) return;

    const { input, output, reasoning, cache } = last.tokens;
    const tokens = input + output + reasoning + cache.read + cache.write;
    if (tokens <= 0) return;
    const model = models.find((model) => model.providerID === last.model.providerID && model.id === last.model.id);
    return { tokens, percent: model?.limit.context ? Math.round((tokens / model.limit.context) * 100) : undefined };
}

export function formatTokens(tokens: number): string {
    if (tokens >= 999_950) return `${(tokens / 1_000_000).toFixed(1)}M`;
    if (tokens >= 1000) return `${(tokens / 1000).toFixed(1)}K`;
    return String(tokens);
}
