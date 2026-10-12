/** @jsxImportSource @opentui/solid */

// Compact VCS status in the OpenCode sidebar. The branch name is left out on
// purpose: the sidebar footer already shows it.

import { Plugin, usePlugin } from "@opencode/plugin/tui";
import { createEffect, createSignal, For, onCleanup, Show } from "solid-js";
import { collectStatus, gitRunner, type StatusSegment, statusSegments } from "./vcs";

const HEADING = "Git";
const REFRESH_MS = 5000;
const REFRESH_EVENTS = [
    "filesystem.changed",
    "session.tool.success",
    "session.execution.succeeded",
    "session.execution.failed",
    "session.execution.interrupted",
] as const;

function Status(props: { sessionID: string }) {
    const api = usePlugin();
    const [segments, setSegments] = createSignal<StatusSegment[]>([]);

    createEffect(() => {
        const location = api.data.session.get(props.sessionID)?.location ?? api.location ?? api.data.location.default();
        const run = gitRunner(location.directory);
        let disposed = false;
        let refreshing = false;
        setSegments([]);

        const refresh = async () => {
            if (disposed || refreshing) return;
            refreshing = true;
            try {
                const status = await collectStatus(run);
                if (!disposed) setSegments(status ? statusSegments(status) : []);
            } catch {
                if (!disposed) setSegments([]);
            } finally {
                refreshing = false;
            }
        };

        void refresh();
        const timer = setInterval(() => void refresh(), REFRESH_MS);
        const subscriptions = REFRESH_EVENTS.map((event) => api.data.on(event, () => void refresh()));
        onCleanup(() => {
            disposed = true;
            clearInterval(timer);
            for (const stop of subscriptions) stop();
        });
    });

    return (
        <Show when={segments().length > 0}>
            <box flexDirection="column" flexShrink={0}>
                <text fg={api.theme.text.base} wrapMode="none">
                    <b>{HEADING}</b>
                </text>
                <For each={segments()}>
                    {(segment) => (
                        <box flexDirection="row" gap={1} flexShrink={0}>
                            <text fg={api.theme.text.muted} wrapMode="none">
                                {segment.label}
                            </text>
                            <Show when={segment.additions > 0}>
                                <text fg={api.theme.diff.text.added} wrapMode="none">
                                    +{segment.additions}
                                </text>
                            </Show>
                            <Show when={segment.deletions > 0}>
                                <text fg={api.theme.diff.text.removed} wrapMode="none">
                                    -{segment.deletions}
                                </text>
                            </Show>
                        </box>
                    )}
                </For>
            </box>
        </Show>
    );
}

export default Plugin.define({
    id: "vcs-status",
    setup(api) {
        return api.ui.slot({
            append: "sidebar.content",
            render: (props) => <Status sessionID={props.sessionID} />,
        });
    },
});
