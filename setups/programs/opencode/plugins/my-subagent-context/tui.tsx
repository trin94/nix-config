/** @jsxImportSource @opentui/solid */

// Context size of every subagent in the current session's tree. Mirrors the
// prompt footer's figure: the last assistant step's tokens against the model limit.
// A click on a row opens that session, as the Claude Code sidebar puts a subagent in the main view.
// OpenCode draws the sidebar only for top-level sessions, so the session shown is always the tree's root.

import { Plugin, usePlugin } from "@opencode/plugin/tui";
import { createEffect, createMemo, createSignal, For, onCleanup, Show } from "solid-js";
import { contextUsage, foldText, formatTokens, type Row, type State, state, tree } from "./tree";

const PERCENT_FROM_TOKENS = 200_000;
const WARNING_TOKENS = 125_000;
const ERROR_TOKENS = 225_000;
const MARK: Record<State, string> = { running: "●", done: "✓", failed: "✗" };

function Subagents(props: { sessionID: string }) {
    const api = usePlugin();
    const session = api.data.session;
    const running = (sessionID: string) => session.status(sessionID) === "running";
    // Clicked folds, kept across session switches until the TUI exits.
    const [folds, updateFolds] = api.storage.memory("folds", { initial: {} as Record<string, boolean> });
    const model = createMemo(() => tree(session.list(), props.sessionID, running, folds));
    const toggle = (row: Row) => {
        updateFolds((draft) => {
            draft[row.session.id] = !row.expanded;
        });
    };
    const view = (sessionID: string) => api.ui.router.navigate({ type: "session", sessionID });
    // The clickable span under the mouse: "row:" or "fold:" and a session ID. Kept here rather
    // than in the row, because rows remount whenever the session list changes.
    const [hovered, setHovered] = createSignal<string>();
    const hover = (key: string) => ({
        onMouseOver: () => {
            setHovered(key);
            api.renderer.setMousePointer("pointer");
        },
        onMouseOut: () => {
            // Moving between spans can deliver the next span's over first.
            if (hovered() !== key) return;
            setHovered(undefined);
            api.renderer.setMousePointer("default");
        },
    });
    onCleanup(() => {
        if (hovered()) api.renderer.setMousePointer("default");
    });
    const hoverBg = (key: string) => (hovered() === key ? api.theme.background.raised.high : undefined);
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
                <text fg={api.theme.text.base} wrapMode="none">
                    <b>Subagents ({model().total})</b>
                </text>
                <For each={model().rows}>
                    {(row) => {
                        const usage = createMemo(() =>
                            contextUsage(
                                session.message.list(row.session.id),
                                api.data.location.model.list(row.session.location) ?? [],
                                row.session.revert?.messageID,
                            ),
                        );
                        const rowState = () => state(row.session, running(row.session.id));
                        const fg = () => (rowState() === "running" ? api.theme.text.base : api.theme.text.muted);
                        const rowKey = `row:${row.session.id}`;
                        const foldKey = `fold:${row.session.id}`;
                        const labelFg = () => (hovered() === rowKey ? api.theme.text.base : fg());
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
                            <box flexDirection="row" gap={1} flexShrink={0}>
                                <box flexDirection="row" flexGrow={1} flexShrink={1} minWidth={0}>
                                    <text fg={api.theme.text.muted} wrapMode="none" flexShrink={0}>
                                        {row.prefix}
                                    </text>
                                    {/* biome-ignore lint/a11y/noStaticElementInteractions: OpenTUI element, no DOM roles */}
                                    <box
                                        flexDirection="row"
                                        flexShrink={1}
                                        minWidth={0}
                                        backgroundColor={hoverBg(rowKey)}
                                        onMouseUp={() => view(row.session.id)}
                                        {...hover(rowKey)}
                                    >
                                        <text fg={markColor(rowState())} wrapMode="none" flexShrink={0}>
                                            {`${MARK[rowState()]} `}
                                        </text>
                                        <text fg={labelFg()} wrapMode="none" truncate flexShrink={1} minWidth={0}>
                                            {label}
                                        </text>
                                    </box>
                                </box>
                                <Show when={foldText(row)}>
                                    {/* biome-ignore lint/a11y/noStaticElementInteractions: OpenTUI element, no DOM roles */}
                                    <text
                                        fg={hovered() === foldKey ? api.theme.text.base : api.theme.text.muted}
                                        bg={hoverBg(foldKey)}
                                        wrapMode="none"
                                        flexShrink={0}
                                        onMouseUp={() => toggle(row)}
                                        {...hover(foldKey)}
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
