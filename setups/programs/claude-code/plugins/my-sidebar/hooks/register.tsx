// A permanent sidebar docked beside the chat, laid out like OpenCode's. This module wires the hooks and
// orders the sections; each section's module reads and draws its own part.

import type { EngineInterface, PaneCloseInput, Register } from "claude-code";
import { atom, read, update } from "claude-code";

import { Context } from "./context";
import { collectStatus, Git, type GitRunner } from "./git";
import { Header } from "./header";
import { Limits } from "./limits";
import { Mcp, mcpServers } from "./mcp";
import { loadedSkills, Skills, skillPromptNames, slashCommands } from "./skills";
import { rememberAgents, Subagents } from "./subagents";
import { currentTodos, Todos } from "./todos";

const PANE = "sidebar";
const TITLE = "Sidebar";
// OpenCode's sidebar width.
const COLUMNS = 42;
// Token readings and agent states change without an event.
const REDRAW_MS = 2000;
// Git, skills, todos and MCP servers are read from outside the engine; the old status line refreshed as often.
const REFRESH_MS = 5000;

// Kept across reloads until the session ends.
const git = atom({ plugin: "my-sidebar", key: "git" } as const, null, { shape: "git-1" });
const skills = atom({ plugin: "my-sidebar", key: "skills" } as const, [], { shape: "skills-1" });
const expanded = atom({ plugin: "my-sidebar", key: "expanded" } as const, [], { shape: "expanded-1" });
const title = atom({ plugin: "my-sidebar", key: "title" } as const, null, { shape: "title-1" });
const effort = atom({ plugin: "my-sidebar", key: "effort" } as const, null, { shape: "effort-1" });
const mode = atom({ plugin: "my-sidebar", key: "mode" } as const, null, { shape: "mode-1" });
const todos = atom({ plugin: "my-sidebar", key: "todos" } as const, [], { shape: "todos-1" });
const mcp = atom({ plugin: "my-sidebar", key: "mcp" } as const, [], { shape: "mcp-1" });

/** A permanent bar, as in OpenCode: the person's close mark and ctrl+x x leave it open. */
export const keepsOpen = (close: PaneCloseInput) => close.id === PANE && close.origin.kind === "person";

async function refresh($: EngineInterface): Promise<void> {
    const cwd = await $.session.cwd();
    const run: GitRunner = async (args) => {
        const result = await $.process.run(["git", "--no-optional-locks", ...args], { cwd });
        return result.exitCode === 0 ? result.stdout.trim() : undefined;
    };

    const home = await $.env.get("HOME");
    const skillDirs = [...new Set([home && `${home}/.claude/skills`, `${cwd}/.claude/skills`])].filter(
        (dir): dir is string => Boolean(dir),
    );
    const messages = await $.session.messages();
    const list = "deny" in messages ? [] : messages;
    // Skills Claude Code expanded while this module ran, plugins' included. A resumed session's earlier
    // ones fall back to the skill folders, which hold no plugin's.
    const slashSkills = new Set(await read($, expanded));
    for (const name of new Set(slashCommands(list))) {
        if (slashSkills.has(name) || name.includes(":")) continue;
        const found = await Promise.all(skillDirs.map((dir) => $.fs.exists(`${dir}/${name}/SKILL.md`)));
        if (found.some(Boolean)) slashSkills.add(name);
    }

    const [status, tools] = await Promise.all([collectStatus(run), $.tool.list()]);
    await update($, git, () => status);
    await update($, skills, () => loadedSkills(list, (name) => slashSkills.has(name)));
    await update($, todos, () => currentTodos(list));
    await update($, mcp, () => mcpServers(tools));
}

// Timers and tool calls overlap; one git pass at a time is enough.
let refreshing = false;

async function refreshOnce($: EngineInterface): Promise<void> {
    if (refreshing) return;
    refreshing = true;
    try {
        await refresh($);
    } catch {
        // Git missing or the session going away: the sections keep their last values until the next tick.
    } finally {
        refreshing = false;
    }
}

async function readHeader($: EngineInterface) {
    const [name, root, home, model, level, permissionMode] = await Promise.all([
        read($, title),
        $.session.root(),
        $.env.get("HOME"),
        $.session.model(),
        read($, effort),
        read($, mode),
    ]);
    return { title: name, root, home, model, effort: level, mode: permissionMode };
}

export const register: Register = (on) => {
    on("session.start", async ($, e, next) => {
        // Unasked, the dock seats it from 144 columns (fullscreen renderer only) and it waits below that.
        void $.ui.open({ id: PANE, title: TITLE, columns: COLUMNS, backgroundColor: "transparent" });
        // A reload stops these timers.
        $.clock.every(REDRAW_MS, () => {
            $.ui.invalidate("ui.render");
            void rememberAgents($);
        });
        $.clock.every(REFRESH_MS, () => void refreshOnce($));
        void refreshOnce($);
        return next(e);
    });

    // Claude Code hands plugins the session title only through these settings-hook events; a /rename
    // shows from the next prompt on.
    on("classic.SessionStart", async ($, e, next) => {
        await update($, title, () => e.session_title ?? null);
        return next(e);
    }).catch((_$, e, next) => next(e));

    on("classic.UserPromptSubmit", async ($, e, next) => {
        await update($, title, () => e.session_title ?? null);
        await update($, mode, () => e.permission_mode ?? null);
        return next(e);
    }).catch((_$, e, next) => next(e));

    // The permission mode reaches plugins only on settings-hook events; shift+tab shows from the next
    // tool call or turn end on. A subagent's events carry its own mode.
    on("classic.PostToolUse", async ($, e, next) => {
        if (e.agent_id === undefined) await update($, mode, () => e.permission_mode ?? null);
        return next(e);
    }).catch((_$, e, next) => next(e));

    on("classic.Stop", async ($, e, next) => {
        await update($, mode, () => e.permission_mode ?? null);
        return next(e);
    }).catch((_$, e, next) => next(e));

    // The effort is known only as each main-loop request goes out; subagents run at their own.
    on("turn.step", async function* ($, e, next) {
        if (e.agentId === undefined) await update($, effort, () => (e.effort === undefined ? null : String(e.effort)));
        return yield* next(e);
    });

    // Tells a skill's slash command from a plain command's, whatever folder or plugin the skill comes from.
    on("skill.prompt", async ($, e, next) => {
        const names = skillPromptNames(e);
        if (names.length > 0) await update($, expanded, (known) => [...new Set([...known, ...names])]);
        return next(e);
    }).catch((_$, e, next) => next(e));

    // Edits, commits and skill loads land through tool calls; catch them before the next tick.
    on("tool.call", async ($, e, next) => {
        const result = await next(e);
        void refreshOnce($);
        return result;
    }).catch((_$, e, next) => next(e));

    on("ui.close", async (_$, e, next) => {
        if (keepsOpen(e)) return { value: undefined };
        return next(e);
    }).catch((_$, e, next) => next(e));

    on("ui.render", { component: "Pane", requestId: PANE }, async ($, e) => {
        const ui = $.ui.resolve(e);
        const [header, usage, now, todoList, loaded, subagents, servers, status] = await Promise.all([
            readHeader($),
            $.session.usage(),
            $.clock.now(),
            read($, todos),
            read($, skills),
            Subagents(ui, $, e.props.view.agentId),
            read($, mcp),
            read($, git),
        ]);

        return (
            <ui.Box flexDirection="column" gap={1} paddingX={1} paddingTop={1}>
                {Header(ui, header)}
                {Context(ui, usage)}
                {Limits(ui, usage.rateLimits, now)}
                {Todos(ui, todoList)}
                {Skills(ui, loaded)}
                {subagents}
                {Mcp(ui, servers)}
                {Git(ui, status)}
            </ui.Box>
        );
    });
};
