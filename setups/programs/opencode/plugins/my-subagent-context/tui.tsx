/** @jsxImportSource @opentui/solid */

// Context size of every subagent in the current session's tree. Mirrors the
// prompt footer's figure: the last assistant step's tokens against the model limit.
// A click on a row opens that session, as the Claude Code sidebar puts a subagent in the main view.

import { Plugin, usePlugin } from "@opencode/plugin/tui";
import { TextAttributes } from "@opentui/core";
import { createEffect, createMemo, For, Show } from "solid-js";
import { contextUsage, foldText, formatTokens, type Row, type State, state, tree } from "./tree";

const PERCENT_FROM_TOKENS = 200_000;
const WARNING_TOKENS = 125_000;
const ERROR_TOKENS = 225_000;
const MAIN = "← Main conversation";
const MARK: Record<State, string> = { running: "●", done: "✓", failed: "✗" };

function Subagents(props: { sessionID: string }) {
    const api = usePlugin();
    const session = api.data.session;
    const running = (sessionID: string) => session.status(sessionID) === "running";
    const root = () => session.root(props.sessionID);
    // Clicked folds, kept across session switches until the TUI exits.
    const [folds, updateFolds] = api.storage.memory("folds", { initial: {} as Record<string, boolean> });
    const model = createMemo(() => tree(session.list(), root(), (id) => running(id) || id === props.sessionID, folds));
    const toggle = (row: Row) => {
        updateFolds((draft) => {
            draft[row.session.id] = !row.expanded;
        });
    };
    const view = (sessionID: string) => api.ui.router.navigate({ type: "session", sessionID });
    const markColor = (value: State) => {
        const { feedback } = api.theme.text;
        if (value === "running") return feedback.info.base;
        return value === "done" ? feedback.success.base : feedback.error.base;
    };

    // The host only loads messages for opened sessions. Once loaded, step events keep them current.
    const requested = new Set<string>();
    createEffect(() => {
        for (const { session: shown } of model().rows) {
            if (requested.has(shown.id)) continue;
            requested.add(shown.id);
            void session.message.sync(shown.id);
        }
    });

    return (
        <Show when={model().rows.length > 0}>
            <box flexDirection="column" flexShrink={0}>
                <box flexDirection="row" gap={1} flexShrink={0}>
                    <text fg={api.theme.text.base} wrapMode="none" flexGrow={1}>
                        <b>Subagents ({model().total})</b>
                    </text>
                    <Show when={props.sessionID !== root()}>
                        {/* biome-ignore lint/a11y/noStaticElementInteractions: OpenTUI element, no DOM roles */}
                        <text
                            fg={api.theme.text.action.primary.selected}
                            wrapMode="none"
                            flexShrink={0}
                            onMouseUp={() => view(root())}
                        >
                            {MAIN}
                        </text>
                    </Show>
                </box>
                <For each={model().rows}>
                    {(row) => {
                        const usage = createMemo(() =>
                            contextUsage(
                                session.message.list(row.session.id),
                                api.data.location.model.list(row.session.location) ?? [],
                                row.session.revert?.messageID,
                            ),
                        );
                        const viewed = () => row.session.id === props.sessionID;
                        const rowState = () => state(row.session, running(row.session.id));
                        const fg = () => (rowState() === "running" ? api.theme.text.base : api.theme.text.muted);
                        const labelFg = () => (viewed() ? api.theme.text.action.primary.selected : fg());
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
                        // Clicking the open session again goes back to the main one, as the Claude Code tasks list does.
                        const open = () => view(viewed() ? root() : row.session.id);
                        return (
                            <box flexDirection="row" gap={1} flexShrink={0}>
                                {/* biome-ignore lint/a11y/noStaticElementInteractions: OpenTUI element, no DOM roles */}
                                <box flexDirection="row" flexGrow={1} flexShrink={1} minWidth={0} onMouseUp={open}>
                                    <text fg={api.theme.text.muted} wrapMode="none" flexShrink={0}>
                                        {row.prefix}
                                    </text>
                                    <text fg={markColor(rowState())} wrapMode="none" flexShrink={0}>
                                        {`${MARK[rowState()]} `}
                                    </text>
                                    <text
                                        fg={labelFg()}
                                        attributes={viewed() ? TextAttributes.BOLD : TextAttributes.NONE}
                                        wrapMode="none"
                                        truncate
                                        flexShrink={1}
                                        minWidth={0}
                                    >
                                        {label}
                                    </text>
                                </box>
                                <Show when={foldText(row)}>
                                    {/* biome-ignore lint/a11y/noStaticElementInteractions: OpenTUI element, no DOM roles */}
                                    <text
                                        fg={api.theme.text.muted}
                                        wrapMode="none"
                                        flexShrink={0}
                                        onMouseUp={() => toggle(row)}
                                    >
                                        {foldText(row)}
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
