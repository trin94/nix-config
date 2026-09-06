/** @jsxImportSource @opentui/solid */

// Compact VCS status in the OpenCode sidebar. The branch name is left out on
// purpose: the sidebar header already shows it.

import { createSignal, For, Show } from "solid-js";
import { collectStatus, gitRunner, type StatusSegment, statusSegments } from "./vcs";

const HEADING = "Git";
// Last section in the sidebar, so it lands directly above the footer's branch line.
const SLOT_ORDER = 900;
const REFRESH_MS = 5000;
const REFRESH_EVENTS = ["file.edited", "file.watcher.updated", "session.idle"];
// TextAttributes.BOLD from @opentui/core, inlined: plugins cannot import that module.
const BOLD = 1;

type Theme = { text: string; textMuted: string; diffAdded: string; diffRemoved: string };

type Api = {
    state: { path: { worktree: string; directory: string } };
    theme: { current: Theme };
    event: { on: (type: string, handler: () => void) => () => void };
    lifecycle: { onDispose: (fn: () => void) => unknown };
    slots: { register: (plugin: unknown) => unknown };
};

function Status(props: { api: Api; segments: () => StatusSegment[] }) {
    const theme = () => props.api.theme.current;
    return (
        <Show when={props.segments().length > 0}>
            <box flexDirection="column" flexShrink={0}>
                <text fg={theme().text} attributes={BOLD} wrapMode="none">
                    {HEADING}
                </text>
                <For each={props.segments()}>
                    {(segment) => (
                        <box flexDirection="row" gap={1} flexShrink={0}>
                            <text fg={theme().textMuted} wrapMode="none">
                                {segment.label}
                            </text>
                            <Show when={segment.additions > 0}>
                                <text fg={theme().diffAdded} wrapMode="none">
                                    +{segment.additions}
                                </text>
                            </Show>
                            <Show when={segment.deletions > 0}>
                                <text fg={theme().diffRemoved} wrapMode="none">
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

export default {
    id: "vcs-status",
    tui: async (api: Api) => {
        const [segments, setSegments] = createSignal<StatusSegment[]>([]);

        let refreshing = false;
        const refresh = async () => {
            if (refreshing) return;
            refreshing = true;
            try {
                const path = api.state.path;
                const status = await collectStatus(gitRunner(path.worktree || path.directory));
                setSegments(status ? statusSegments(status) : []);
            } catch {
                setSegments([]);
            } finally {
                refreshing = false;
            }
        };

        void refresh();

        const timer = setInterval(() => void refresh(), REFRESH_MS);
        api.lifecycle.onDispose(() => clearInterval(timer));
        for (const event of REFRESH_EVENTS) {
            const off = api.event.on(event, () => void refresh());
            api.lifecycle.onDispose(off);
        }

        api.slots.register({
            order: SLOT_ORDER,
            slots: {
                sidebar_content: () => <Status api={api} segments={segments} />,
            },
        });
    },
};
