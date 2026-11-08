import { homedir } from "node:os";
import { basename, dirname, resolve } from "node:path";
import { type ExtensionAPI, type ExtensionContext, parseSkillBlock } from "@earendil-works/pi-coding-agent";

/** Shows the skills loaded into this session, in first-use order, as the "skills" footer status. */
export default function (pi: ExtensionAPI) {
    const skills = new Set<string>();
    const reads = new Map<string, string>();

    const show = (ctx: ExtensionContext) => {
        const text = skills.size > 0 ? ctx.ui.theme.fg("dim", `skills: ${[...skills].join(", ")}`) : undefined;
        ctx.ui.setStatus("skills", text);
    };

    const isSkill = (name: string) => pi.getCommands().some((c) => c.source === "skill" && c.name === `skill:${name}`);

    /** The skill whose SKILL.md is at `path`, preferring the registered name over the directory name. */
    const skillAt = (path: string, cwd: string) => {
        const file = resolve(cwd, path.replace(/^~(?=$|\/)/, homedir()));
        if (basename(file) !== "SKILL.md") return undefined;
        const command = pi.getCommands().find((c) => c.source === "skill" && c.sourceInfo.path === file);
        return command?.name.replace(/^skill:/, "") ?? basename(dirname(file));
    };

    const track = (id: string, tool: string, args: unknown) => {
        if (tool !== "read" || typeof args !== "object" || args === null || !("path" in args)) return;
        if (typeof args.path === "string") reads.set(id, args.path);
    };

    const finish = (id: string, isError: boolean, cwd: string) => {
        const path = reads.get(id);
        reads.delete(id);
        const name = path && !isError ? skillAt(path, cwd) : undefined;
        if (name) skills.add(name);
    };

    /** Replays the current branch, so resumed, forked and tree-navigated sessions show their skills. */
    const rebuild = (ctx: ExtensionContext) => {
        skills.clear();
        reads.clear();
        for (const entry of ctx.sessionManager.getBranch()) {
            if (entry.type !== "message") continue;
            const message = entry.message;
            if (message.role === "user") {
                const { content } = message;
                const text = typeof content === "string" ? content : content[0]?.type === "text" ? content[0].text : "";
                const name = parseSkillBlock(text)?.name;
                if (name) skills.add(name);
            } else if (message.role === "assistant") {
                for (const part of message.content) {
                    if (part.type === "toolCall") track(part.id, part.name, part.arguments);
                }
            } else if (message.role === "toolResult") {
                finish(message.toolCallId, message.isError, ctx.cwd);
            }
        }
        reads.clear();
        show(ctx);
    };

    pi.on("session_start", (_event, ctx) => rebuild(ctx));
    pi.on("session_tree", (_event, ctx) => rebuild(ctx));

    pi.on("input", (event, ctx) => {
        const name = event.text.match(/^\/skill:(\S+)/)?.[1];
        if (!name || !isSkill(name)) return;
        skills.add(name);
        show(ctx);
    });

    pi.on("tool_execution_start", (event) => track(event.toolCallId, event.toolName, event.args));

    pi.on("tool_execution_end", (event, ctx) => {
        finish(event.toolCallId, event.isError, ctx.cwd);
        show(ctx);
    });
}
