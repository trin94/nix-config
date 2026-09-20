import { realpathSync } from "node:fs";
import { homedir } from "node:os";
import { basename, resolve } from "node:path";
import { parseFrontmatter, parseSkillBlock, type SessionEntry, type Skill } from "@earendil-works/pi-coding-agent";

type SkillLocation = Pick<Skill, "name" | "filePath">;

/** Successful skill loads on this session branch, in first-use order, including pre-compaction history. */
export function loadedSkills(
    entries: readonly SessionEntry[],
    catalog: readonly SkillLocation[],
    cwd: string,
): string[] {
    const paths = new Map<string, string>();
    const canonical = (input: string): string => {
        const cached = paths.get(input);
        if (cached) return cached;
        const unquoted = input.replace(/^@/, "");
        const expanded = unquoted.startsWith("~/") ? resolve(homedir(), unquoted.slice(2)) : resolve(cwd, unquoted);
        let path = expanded;
        try {
            path = realpathSync(expanded);
        } catch {
            // Old session paths can disappear after a package update or Nix garbage collection.
        }
        paths.set(input, path);
        return path;
    };
    const namesByPath = new Map(catalog.map((skill) => [canonical(skill.filePath), skill.name]));
    const reads = new Map<string, string>();
    const names = new Set<string>();

    for (const entry of entries) {
        if (entry.type !== "message") continue;
        const message = entry.message;
        if (message.role === "user") {
            const text =
                typeof message.content === "string"
                    ? message.content
                    : message.content
                          .filter((part) => part.type === "text")
                          .map((part) => part.text)
                          .join("\n");
            const skill = parseSkillBlock(text);
            if (skill) names.add(skill.name);
        } else if (message.role === "assistant") {
            for (const part of message.content) {
                if (part.type === "toolCall" && part.name === "read" && typeof part.arguments.path === "string") {
                    reads.set(part.id, part.arguments.path);
                }
            }
        } else if (message.role === "toolResult" && message.toolName === "read" && !message.isError) {
            const path = reads.get(message.toolCallId);
            if (!path) continue;
            const known = namesByPath.get(canonical(path));
            if (known) {
                names.add(known);
            } else if (basename(path) === "SKILL.md") {
                // The skill may no longer be installed. Recover its name from the successful read,
                // not the directory name (Pi permits those to differ).
                const text = message.content
                    .filter((part) => part.type === "text")
                    .map((part) => part.text)
                    .join("\n");
                try {
                    const { frontmatter } = parseFrontmatter<{ name?: unknown }>(text);
                    if (typeof frontmatter.name === "string" && frontmatter.name.trim()) names.add(frontmatter.name);
                } catch {
                    // A malformed or partial historical read is not evidence of a named skill load.
                }
            }
        }
    }
    return [...names];
}
