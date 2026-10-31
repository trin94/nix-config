/** @jsxImportSource @opentui/solid */

// Context size of every subagent in the current session's tree. Mirrors the
// prompt footer's figure: the last assistant step's tokens against the model limit.

import type { ModelInfo, SessionInfo, SessionMessageInfo } from "@opencode/client";
import { Plugin, usePlugin } from "@opencode/plugin/tui";
import { createEffect, createMemo, For, Show } from "solid-js";

const HEADING = "Subagents";
const PERCENT_FROM_TOKENS = 200_000;
const WARNING_TOKENS = 125_000;
const ERROR_TOKENS = 225_000;

interface Row {
    session: SessionInfo;
    prefix: string;
    /** Descendants folded away under this row. */
    hidden: number;
    expanded: boolean;
    hasChildren: boolean;
}

/**
 * Descendants of `rootID` in depth-first order, with tree-drawing prefixes.
 * A subtree with no open session folds into its top row unless `overrides` says otherwise.
 */
function tree(
    sessions: readonly SessionInfo[],
    rootID: string,
    open: (sessionID: string) => boolean,
    overrides: Readonly<Record<string, boolean>>,
): Row[] {
    const children = new Map<string, SessionInfo[]>();
    for (const session of sessions) {
        if (!session.parentID) continue;
        children.set(session.parentID, [...(children.get(session.parentID) ?? []), session]);
    }
    const descendants = (sessionID: string): SessionInfo[] =>
        (children.get(sessionID) ?? []).flatMap((child) => [child, ...descendants(child.id)]);

    const walk = (parentID: string, indent: string): Row[] => {
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
    return walk(rootID, "");
}

/** Tokens of the last assistant step since the latest compaction, as in OpenCode's prompt footer. */
function contextUsage(messages: readonly SessionMessageInfo[], models: readonly ModelInfo[], boundary?: string) {
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

function formatTokens(tokens: number): string {
    if (tokens >= 999_950) return `${(tokens / 1_000_000).toFixed(1)}M`;
    if (tokens >= 1000) return `${(tokens / 1000).toFixed(1)}K`;
    return String(tokens);
}

function Subagents(props: { sessionID: string }) {
    const api = usePlugin();
    const session = api.data.session;
    const running = (sessionID: string) => session.status(sessionID) === "running";
    // Clicked folds, kept across session switches until the TUI exits.
    const [folds, updateFolds] = api.storage.memory("folds", { initial: {} as Record<string, boolean> });
    const rows = createMemo(() =>
        tree(session.list(), session.root(props.sessionID), (id) => running(id) || id === props.sessionID, folds),
    );
    const toggle = (row: Row) => {
        if (!row.hasChildren) return;
        updateFolds((draft) => {
            draft[row.session.id] = !row.expanded;
        });
    };

    // The host only loads messages for opened sessions. Once loaded, step events keep them current.
    const requested = new Set<string>();
    createEffect(() => {
        for (const { session: shown } of rows()) {
            if (requested.has(shown.id)) continue;
            requested.add(shown.id);
            void session.message.sync(shown.id);
        }
    });

    return (
        <Show when={rows().length > 0}>
            <box flexDirection="column" flexShrink={0}>
                <text fg={api.theme.text.base} wrapMode="none">
                    <b>{HEADING}</b>
                </text>
                <For each={rows()}>
                    {(row) => {
                        const usage = createMemo(() =>
                            contextUsage(
                                session.message.list(row.session.id),
                                api.data.location.model.list(row.session.location) ?? [],
                                row.session.revert?.messageID,
                            ),
                        );
                        const fg = () =>
                            running(row.session.id) || row.session.id === props.sessionID
                                ? api.theme.text.base
                                : api.theme.text.muted;
                        const usageFg = () => {
                            const tokens = usage()?.tokens ?? 0;
                            if (tokens >= ERROR_TOKENS) return api.theme.text.feedback.error.base;
                            if (tokens >= WARNING_TOKENS) return api.theme.text.feedback.warning.base;
                            return fg();
                        };
                        const usageText = () => {
                            const value = usage();
                            if (!value) return;
                            const tokens = formatTokens(value.tokens);
                            if (value.percent === undefined || value.tokens < PERCENT_FROM_TOKENS) return tokens;
                            return `${tokens} ${value.percent}%`;
                        };
                        const label = row.session.title ?? row.session.agent ?? row.session.id;
                        return (
                            // biome-ignore lint/a11y/noStaticElementInteractions: OpenTUI box, no DOM roles
                            <box flexDirection="row" gap={1} flexShrink={0} onMouseUp={() => toggle(row)}>
                                <box flexDirection="row" flexGrow={1} flexShrink={1} minWidth={0}>
                                    <text fg={fg()} wrapMode="none" flexShrink={0}>
                                        {row.prefix}
                                    </text>
                                    <text fg={fg()} wrapMode="none" truncate flexShrink={1} minWidth={0}>
                                        {label}
                                    </text>
                                </box>
                                <Show when={row.hidden > 0}>
                                    <text fg={api.theme.text.muted} wrapMode="none" flexShrink={0}>
                                        +{row.hidden}
                                    </text>
                                </Show>
                                <Show when={usageText()}>
                                    <text fg={usageFg()} wrapMode="none" flexShrink={0}>
                                        {usageText()}
                                    </text>
                                </Show>
                            </box>
                        );
                    }}
                </For>
            </box>
        </Show>
    );
}

export default Plugin.define({
    id: "my-subagent-context",
    setup(api) {
        return api.ui.slot({
            append: "sidebar.content",
            render: (props) => <Subagents sessionID={props.sessionID} />,
        });
    },
});
