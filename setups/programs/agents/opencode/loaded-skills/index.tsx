/** @jsxImportSource @opentui/solid */

import type { TuiPlugin, TuiPluginApi } from "@opencode-ai/plugin/tui";
import { createMemo, For, Show } from "solid-js";

function Skills(props: { api: TuiPluginApi; sessionID: string }) {
    const theme = () => props.api.theme.current;
    const skills = createMemo(() => {
        const names = new Set<string>();
        for (const message of props.api.state.session.messages(props.sessionID)) {
            for (const part of props.api.state.part(message.id)) {
                if (part.type !== "tool" || part.tool !== "skill" || part.state.status !== "completed") continue;
                const name = part.state.input.name;
                if (typeof name === "string" && name.length > 0) names.add(name);
            }
        }
        return [...names];
    });

    return (
        <Show when={skills().length > 0}>
            <box flexDirection="column" flexShrink={0}>
                <text fg={theme().text}>
                    <b>Skills ({skills().length})</b>
                </text>
                <For each={skills()}>{(name) => <text fg={theme().textMuted}>{name}</text>}</For>
            </box>
        </Show>
    );
}

const tui: TuiPlugin = async (api) => {
    api.slots.register({
        order: 150,
        slots: {
            sidebar_content(_context, props) {
                return <Skills api={api} sessionID={props.session_id} />;
            },
        },
    });
};

export default { id: "loaded-skills", tui };
