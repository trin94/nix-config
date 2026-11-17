// Skills loaded into the main conversation, in first-use order, as in OpenCode's my-loaded-skills.

import type { SessionMessage, SkillPromptInput } from "claude-code";

import type { Ui } from "./ui";

const COMMAND = /<command-name>\/([^<\s]+)<\/command-name>/g;

/** Commands the person ran in a user message's text, without their slash. */
export function slashCommands(messages: readonly SessionMessage[]): string[] {
    return messages
        .filter((message) => message.role === "user")
        .flatMap((message) => [...message.text.matchAll(COMMAND)].map((match) => match[1] ?? ""));
}

/**
 * The names a slash command may spell an expanded skill by: bare, and `plugin:skill` for a plugin's.
 * None for a plain command file, which expands through the same event.
 */
export function skillPromptNames(prompt: Pick<SkillPromptInput, "skill" | "pluginName" | "path">): string[] {
    if (prompt.path !== undefined && !prompt.path.endsWith("/SKILL.md")) return [];
    const name = prompt.skill.replace(/^\//, "");
    if (!prompt.pluginName || name.includes(":")) return [name];
    return [name, `${prompt.pluginName}:${name}`];
}

/**
 * Skill tool calls that didn't fail, and skills the person ran as a slash command.
 * `isSkill` tells a skill's slash command from a built-in's.
 */
export function loadedSkills(messages: readonly SessionMessage[], isSkill: (name: string) => boolean): string[] {
    const names = new Set<string>();
    for (const message of messages) {
        if (message.role === "user") {
            for (const name of slashCommands([message])) if (isSkill(name)) names.add(name);
            continue;
        }
        for (const use of message.toolUses) {
            if (use.tool !== "Skill" || use.isError) continue;
            const skill = use.input.skill;
            if (typeof skill === "string" && skill.length > 0) names.add(skill.replace(/^\//, ""));
        }
    }
    return [...names];
}

export function Skills({ Box, Text }: Ui, skills: readonly string[]) {
    if (skills.length === 0) return null;
    return (
        <Box flexDirection="column">
            <Text bold>Skills ({skills.length})</Text>
            {skills.map((name) => (
                <Text dimColor wrap="truncate-end">
                    {name}
                </Text>
            ))}
        </Box>
    );
}
