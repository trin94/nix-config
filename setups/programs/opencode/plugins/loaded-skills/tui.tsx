/** @jsxImportSource @opentui/solid */

import type { SessionMessageInfo } from "@opencode/client";
import { Plugin, usePlugin } from "@opencode/plugin/tui";
import { createMemo, For, Show } from "solid-js";

/** Skills loaded into this session, in first-use order, including manually attached skills. */
function loadedSkills(messages: readonly SessionMessageInfo[]): string[] {
    const names = new Set<string>();
    const add = (name: unknown) => {
        if (typeof name === "string" && name.length > 0) names.add(name);
    };

    for (const message of messages) {
        if (message.type === "skill") add(message.name);
        if (message.type === "user") {
            for (const skill of message.skills ?? []) add(skill.name);
        }
        if (message.type !== "assistant") continue;
        for (const part of message.content) {
            if (part.type !== "tool" || part.name !== "skill" || part.state.status !== "completed") continue;
            // V2 accepts an ID and returns the display name in metadata; old history may have input.name.
            add(part.state.metadata?.name ?? part.state.input.name ?? part.state.input.id);
        }
    }
    return [...names];
}

function Skills(props: { sessionID: string }) {
    const api = usePlugin();
    const skills = createMemo(() => loadedSkills(api.data.session.message.list(props.sessionID)));

    return (
        <Show when={skills().length > 0}>
            <box flexDirection="column" flexShrink={0}>
                <text fg={api.theme.text.base}>
                    <b>Skills ({skills().length})</b>
                </text>
                <For each={skills()}>{(name) => <text fg={api.theme.text.muted}>{name}</text>}</For>
            </box>
        </Show>
    );
}

export default Plugin.define({
    id: "loaded-skills",
    setup(api) {
        return api.ui.slot({
            append: "sidebar.content",
            render: (props) => <Skills sessionID={props.sessionID} />,
        });
    },
});
