import type { AgentInfo, On, SessionMessage, SessionUsage, ToolInfo } from "claude-code";
import { expect, mock, test } from "claude-code/testing";
import { contextRows, costText } from "../hooks/context";
import { parseNumstat, statusSegments } from "../hooks/git";
import { homeRelative, modelLine } from "../hooks/header";
import { limitRows, percentColor, resetText } from "../hooks/limits";
import { mcpServers } from "../hooks/mcp";
import { keepsOpen } from "../hooks/register";
import { loadedSkills, skillPromptNames } from "../hooks/skills";
import { currentTodos, hasOpenTodos } from "../hooks/todos";

const PANE = {
    plugin: "my-sidebar",
    component: "Pane",
    requestId: "sidebar",
    props: {
        title: "Sidebar",
        isFocused: false,
        bodyColumns: 42,
        placement: "dock",
        scroll: { offset: 0, bodyRows: 40 },
        view: {},
    },
} as const;

const agent = (id: string, fields: Partial<AgentInfo>): AgentInfo => ({
    id,
    description: id,
    type: "general-purpose",
    status: "completed",
    kind: "local_agent",
    taskStatus: "completed",
    label: id,
    startTime: 0,
    cwd: "/",
    tokenCount: 0,
    tokenSamples: [],
    hasRow: true,
    ...fields,
});

const AGENTS = [
    agent("done-parent", { startTime: 1, tokenCount: 1500 }),
    agent("done-child", { parentId: "done-parent", startTime: 2 }),
    agent("live-parent", { startTime: 3, status: "running", tokenCount: 210_000, contextWindowSize: 1_000_000 }),
    agent("live-child", { parentId: "live-parent", startTime: 4, status: "running" }),
];

const USAGE: SessionUsage = {
    startedAt: 0,
    context: { tokens: 156_000, window: 1_000_000, percent: 16 },
    rateLimits: [],
};

type Sidebar = {
    /** A function to change the listing mid-test. */
    agents?: AgentInfo[] | (() => AgentInfo[]);
    usage?: SessionUsage;
    /** False where the test drives a `mock.clock` of its own. */
    withClock?: boolean;
};

/** The engine reads the pane makes on every draw, answered with a session at ~/.dotfiles. */
function sidebar(on: On, { agents = [], usage = USAGE, withClock = true }: Sidebar = {}) {
    on("agent.list", () => ({ value: typeof agents === "function" ? agents() : agents }));
    on("session.usage", () => ({ value: usage }));
    on("session.root", () => ({ value: "/home/elias/.dotfiles" }));
    on("env.get", () => ({ value: "/home/elias" }));
    on("session.model", () => ({ value: "claude-opus-5-5" }));
    if (withClock) on("clock.now", () => ({ value: new Date(2026, 10, 17, 9, 0).getTime() }));
}

const assistant = (toolUses: SessionMessage["toolUses"]): SessionMessage => ({ role: "assistant", text: "", toolUses });

for (const surface of ["terminal", "desktop"] as const) {
    test(`subagents: finished subtrees fold, active ones open, on ${surface}`, async ($, on) => {
        sidebar(on, { agents: AGENTS });

        const ui = await $.ui.mount({ ...PANE, surface });

        expect((await ui.find({ type: "Text", text: /^Subagents$/ }))?.text).toBe("Subagents");
        expect((await ui.find({ type: "Text", text: /done-parent/ }))?.text).toBe("done-parent");
        expect(await ui.find({ type: "Text", text: /done-child/ })).toBeUndefined();
        expect((await ui.find({ type: "Button", key: "done-parent" }))?.text).toBe("+1");
        expect((await ui.find({ type: "Text", text: /live-child/ }))?.text).toBe("live-child");
        expect((await ui.find({ type: "Text", text: /^1\.5K$/ }))?.text).toBe("1.5K");
        expect((await ui.find({ type: "Text", text: /^210/ }))?.text).toBe("210.0K 21%");

        await ui.press({ key: "done-parent" });
        expect((await ui.find({ type: "Text", text: /done-child/ }))?.text).toBe("done-child");
        await ui.unmount();
    });
}

test("context shows the main conversation's tokens and share", async ($, on) => {
    sidebar(on);

    const ui = await $.ui.mount({ ...PANE, surface: "terminal" });

    expect((await ui.find({ type: "Text", text: /^Context$/ }))?.text).toBe("Context");
    expect((await ui.find({ type: "Text", text: /tokens/ }))?.text).toBe("156.0K / 1.0M tokens");
    expect((await ui.find({ type: "Text", text: /used/ }))?.text).toBe("16% used");
    expect(await ui.find({ type: "Text", text: /^Subagents$/ })).toBeUndefined();
    await ui.unmount();
});

test("context waits for the first response", () => {
    expect(contextRows({ window: 1_000_000 })).toEqual([]);
});

for (const [tokens, color] of [
    [124_999, undefined],
    [125_000, "warning"],
    [225_000, "error"],
] as const) {
    test(`context at ${tokens} tokens is coloured ${color ?? "muted"}, as a subagent's`, async ($, on) => {
        sidebar(on, { usage: { ...USAGE, context: { tokens, window: 1_000_000, percent: 20 } } });

        const ui = await $.ui.mount({ ...PANE, surface: "terminal" });

        for (const text of [/tokens$/, /used$/]) {
            const line = await ui.find({ type: "Text", text });
            expect(line?.props.color).toBe(color);
            expect(Boolean(line?.props.dimColor)).toBe(color === undefined);
        }
        await ui.unmount();
    });
}

test("skills: successful Skill calls and skill slash commands, in first-use order", () => {
    const messages: SessionMessage[] = [
        { role: "user", text: "<command-name>/grilling</command-name>", toolUses: [] },
        { role: "user", text: "<command-name>/clear</command-name>", toolUses: [] },
        {
            role: "assistant",
            text: "",
            toolUses: [
                { tool: "Skill", input: { skill: "reporting" }, tool_use_id: "t0" },
                { tool: "Skill", input: { skill: "missing" }, isError: true, tool_use_id: "t1" },
                { tool: "Skill", input: { skill: "grilling" }, tool_use_id: "t2" },
                { tool: "Bash", input: { command: "ls" }, tool_use_id: "t3" },
            ],
        },
    ];

    expect(loadedSkills(messages, (name) => name !== "clear")).toEqual(["grilling", "reporting"]);
});

test("git: branch and uncommitted lines, binary-only changes as a file count", () => {
    expect(parseNumstat("3\t1\ta.ts\n-\t-\tlogo.png\n")).toEqual({ files: 2, additions: 3, deletions: 1 });
    expect(
        statusSegments({
            head: "feature",
            base: "main",
            branch: { files: 1, additions: 0, deletions: 0 },
            dirty: { files: 2, additions: 4, deletions: 1 },
        }),
    ).toEqual([
        { label: "Since main: 1 file", additions: 0, deletions: 0 },
        { label: "Uncommitted: 2 files", additions: 4, deletions: 1 },
    ]);
});

test("the bar opens docked at session start", async ($, on) => {
    const opened: unknown[] = [];
    on("ui.open", (_, e) => (opened.push(e), { value: { isPlaced: true } }));
    on("session.start", (_, e) => ({ cwd: e.cwd }));

    await $.session.start({ cwd: "/", surface: "terminal", isInteractive: true });

    expect(opened).toEqual([{ id: "sidebar", title: "Sidebar", columns: 42, backgroundColor: "transparent" }]);
});

test("the person's close leaves the bar open, the plugin's and an unload's go through", () => {
    expect(keepsOpen({ id: "sidebar", origin: { kind: "person" } })).toBe(true);
    expect(keepsOpen({ id: "sidebar", origin: { kind: "plugin" } })).toBe(false);
    expect(keepsOpen({ id: "sidebar", origin: { kind: "unload" } })).toBe(false);
    expect(keepsOpen({ id: "other", origin: { kind: "person" } })).toBe(false);
});

test("the header shows the session title from the last prompt, and the directory", async ($, on) => {
    sidebar(on);
    on("classic.UserPromptSubmit", () => ({}));

    await $.classic.UserPromptSubmit({ prompt: "hi", session_title: "Sidebar padding" });
    const ui = await $.ui.mount({ ...PANE, surface: "terminal" });

    expect((await ui.find({ type: "Text", text: /^Sidebar padding$/ }))?.text).toBe("Sidebar padding");
    expect((await ui.find({ type: "Text", text: /dotfiles/ }))?.text).toBe("~/.dotfiles");
    await ui.unmount();
});

test("the directory abbreviates home only at a path boundary", () => {
    expect(homeRelative("/home/elias", "/home/elias")).toBe("~");
    expect(homeRelative("/home/elias/git/x", "/home/elias")).toBe("~/git/x");
    expect(homeRelative("/home/eliasx", "/home/elias")).toBe("/home/eliasx");
    expect(homeRelative("/srv", undefined)).toBe("/srv");
});

test("the header shows the model with the effort the main loop last sent", async ($, on) => {
    sidebar(on);

    const ui = await $.ui.mount({ ...PANE, surface: "terminal" });
    expect((await ui.find({ type: "Text", text: /opus/ }))?.text).toBe("claude-opus-5-5");
    await ui.unmount();

    expect(modelLine("claude-opus-5-5", "high")).toBe("claude-opus-5-5 · high");
});

test("the model line adds the permission mode, leaving out default", () => {
    expect(modelLine("claude-opus-5-5", "high", "auto")).toBe("claude-opus-5-5 · high · auto");
    expect(modelLine("claude-opus-5-5", "high", "default")).toBe("claude-opus-5-5 · high");
    expect(modelLine("claude-opus-5-5", null, "plan")).toBe("claude-opus-5-5 · plan");
});

test("the mode follows the main loop's events, not a subagent's", async ($, on) => {
    sidebar(on);
    on("classic.UserPromptSubmit", () => ({}));
    on("classic.PostToolUse", () => ({}));

    await $.classic.UserPromptSubmit({ prompt: "hi", permission_mode: "plan" });
    await $.classic.PostToolUse({
        tool_name: "Bash",
        tool_input: {},
        tool_response: {},
        tool_use_id: "t",
        permission_mode: "bypassPermissions",
        agent_id: "sub",
    });
    const ui = await $.ui.mount({ ...PANE, surface: "terminal" });

    expect((await ui.find({ type: "Text", text: /opus/ }))?.text).toBe("claude-opus-5-5 · plan");
    await ui.unmount();
});

test("context adds the cost estimate, marked when a price was unknown", () => {
    expect(costText(undefined)).toBeUndefined();
    expect(costText({ usd: 1.234 })).toBe("$1.23 spent");
    expect(costText({ usd: 0.5, hasUnknownPrice: true })).toBe("~$0.50 spent");
});

test("limits: each window's share, coloured from 70% and 90%, with the time left until its reset", async ($, on) => {
    const now = new Date(2026, 10, 17, 9, 0).getTime();
    const later = new Date(2026, 10, 17, 14, 30).toISOString();
    const nextWeek = new Date(2026, 10, 23, 13, 5).toISOString();
    sidebar(on, {
        usage: {
            ...USAGE,
            rateLimits: [
                { kind: "five_hour", percentUsed: 72, resetsAt: later },
                { kind: "seven_day", percentUsed: 18, resetsAt: nextWeek },
            ],
        },
    });

    expect(limitRows([{ kind: "spend_limit", percentUsed: 95 }], now)).toEqual([
        { label: "Spend", percent: 95, resets: undefined },
    ]);
    expect(resetText(nextWeek, now)).toBe("6d 4h");
    expect(resetText(new Date(now + 42 * 60_000 + 30_000).toISOString(), now)).toBe("42m");
    expect(resetText(new Date(now - 60_000).toISOString(), now)).toBe("0m");
    expect([percentColor(69.9), percentColor(70), percentColor(90)]).toEqual([undefined, "warning", "error"]);

    const ui = await $.ui.mount({ ...PANE, surface: "terminal" });
    expect((await ui.find({ type: "Text", text: /^72%$/ }))?.props.color).toBe("warning");
    expect((await ui.find({ type: "Text", text: /5h 30m/ }))?.text).toBe("· 5h 30m");
    expect((await ui.find({ type: "Text", text: /^Week$/ }))?.text).toBe("Week");
    await ui.unmount();
});

test("todo: the last TodoWrite list", () => {
    const messages = [
        assistant([
            {
                tool: "TodoWrite",
                tool_use_id: "a",
                input: { todos: [{ content: "old", status: "pending", activeForm: "Old" }] },
            },
        ]),
        assistant([
            {
                tool: "TodoWrite",
                tool_use_id: "b",
                input: {
                    todos: [
                        { content: "Port git", status: "completed", activeForm: "Porting" },
                        { content: "Add limits", status: "in_progress", activeForm: "Adding" },
                    ],
                },
            },
        ]),
    ];

    expect(currentTodos(messages)).toEqual([
        { content: "Port git", status: "completed" },
        { content: "Add limits", status: "in_progress" },
    ]);
});

test("todo: tasks built from TaskCreate and TaskUpdate, deletions dropped", () => {
    const messages = [
        assistant([
            { tool: "TaskCreate", tool_use_id: "1", input: {}, result: { task: { id: "1", subject: "Port git" } } },
            { tool: "TaskCreate", tool_use_id: "2", input: {}, result: { task: { id: "2", subject: "Draft" } } },
            { tool: "TaskCreate", tool_use_id: "3", input: {}, result: { task: { id: "3", subject: "Gone" } } },
            { tool: "TaskUpdate", tool_use_id: "4", input: { taskId: "1", status: "completed" } },
            { tool: "TaskUpdate", tool_use_id: "5", input: { taskId: "2", subject: "Add limits" } },
            { tool: "TaskUpdate", tool_use_id: "6", input: { taskId: "3", status: "deleted" } },
            { tool: "TaskUpdate", tool_use_id: "7", input: { taskId: "2", status: "in_progress" }, isError: true },
        ]),
    ];

    expect(currentTodos(messages)).toEqual([
        { content: "Port git", status: "completed" },
        { content: "Add limits", status: "pending" },
    ]);
});

test("todo: shown while anything is open", () => {
    expect(hasOpenTodos([])).toBe(false);
    expect(hasOpenTodos([{ content: "a", status: "completed" }])).toBe(false);
    expect(
        hasOpenTodos([
            { content: "a", status: "completed" },
            { content: "b", status: "pending" },
        ]),
    ).toBe(true);
});

test("mcp: connected servers from the session's tools, claude.ai connectors as /mcp names them", () => {
    const tool = (name: string, mcp: boolean): ToolInfo => ({ name, description: "", mcp });

    expect(
        mcpServers([
            tool("Bash", false),
            tool("mcp__claude_ai_Google_Drive__search_files", true),
            tool("mcp__claude_ai_Google_Drive__read_file_content", true),
            tool("mcp__github__create_issue", true),
        ]),
    ).toEqual([
        { name: "claude.ai Google Drive", tools: 2 },
        { name: "github", tools: 1 },
    ]);
});

test("subagents: a click opens the agent's transcript, a click on the viewed one returns to the chat", async ($, on) => {
    sidebar(on, { agents: AGENTS });
    const views: unknown[] = [];
    on("ui.view", (_, e) => (views.push(e), { value: {} }));

    const main = await $.ui.mount({ ...PANE, surface: "terminal" });
    await main.press({ key: "view-live-child" });
    await main.unmount();

    const viewing = await $.ui.mount({
        ...PANE,
        surface: "terminal",
        props: { ...PANE.props, view: { agentId: "live-child" } },
    });
    expect((await viewing.find({ type: "Text", text: /^live-child$/ }))?.props.bold).toBe(true);
    await viewing.press({ key: "view-live-child" });
    await viewing.unmount();

    expect(views).toEqual([{ agentId: "live-child" }, {}]);
});

test("subagents: a switch the engine refuses says why", async ($, on) => {
    sidebar(on, { agents: AGENTS });
    const toasts: unknown[] = [];
    on("ui.view", () => ({ value: { deny: "the tasks list shows no such agent" } }));
    on("ui.toast", (_, e) => (toasts.push(e), { value: undefined }));

    const ui = await $.ui.mount({ ...PANE, surface: "terminal" });
    await ui.press({ key: "view-done-parent" });
    await ui.unmount();

    expect(toasts).toEqual([expect.objectContaining({ text: "the tasks list shows no such agent" })]);
});

test("the Subagents heading offers the way back while a subagent's conversation is in view", async ($, on) => {
    sidebar(on, { agents: AGENTS });
    const views: unknown[] = [];
    on("ui.view", (_, e) => (views.push(e), { value: {} }));

    const main = await $.ui.mount({ ...PANE, surface: "terminal" });
    expect(await main.find({ type: "Button", key: "view-main" })).toBeUndefined();
    await main.unmount();

    const viewing = await $.ui.mount({
        ...PANE,
        surface: "terminal",
        props: { ...PANE.props, view: { agentId: "live-child" } },
    });
    expect((await viewing.find({ type: "Button", key: "view-main" }))?.text).toBe("← Main conversation");
    expect((await viewing.find({ type: "Text", text: /Main conversation/ }))?.props.color).toBe("suggestion");
    await viewing.press({ key: "view-main" });
    await viewing.unmount();

    expect(views).toEqual([{}]);
});

test("a subagent Claude Code dropped stays listed, finished and no longer clickable", async ($, on) => {
    const clock = mock.clock(on);
    let listed = [agent("hello", { startTime: 1, status: "running", tokenCount: 37_461 })];
    sidebar(on, { agents: () => listed, withClock: false });
    on("session.start", (_, e) => ({ cwd: e.cwd }));
    on("ui.open", () => ({ value: { isPlaced: true } }));

    await $.session.start({ cwd: "/", surface: "terminal", isInteractive: true });
    await clock.advance(2000);
    listed = [];

    const ui = await $.ui.mount({ ...PANE, surface: "terminal" });
    const row = await ui.find({ type: "Text", text: /^hello$/ });
    expect(row?.props.dimColor).toBe(true);
    expect(await ui.find({ type: "Button", key: "view-hello" })).toBeUndefined();
    expect((await ui.find({ type: "Text", text: /37\.5K/ }))?.text).toBe("37.5K");
    await ui.unmount();
});

test("skills: an expanded skill answers to its bare and plugin-prefixed name; a command file to none", () => {
    expect(skillPromptNames({ skill: "reporting", path: "/home/elias/.claude/skills/reporting/SKILL.md" })).toEqual([
        "reporting",
    ]);
    expect(skillPromptNames({ skill: "simplify" })).toEqual(["simplify"]);
    expect(
        skillPromptNames({
            skill: "modernize",
            pluginName: "code-modernization",
            path: "/plugins/code-modernization/skills/modernize/SKILL.md",
        }),
    ).toEqual(["modernize", "code-modernization:modernize"]);
    expect(skillPromptNames({ skill: "deploy", path: "/repo/.claude/commands/deploy.md" })).toEqual([]);
});

test("skills: a plugin's skill run as a slash command is listed", async ($, on) => {
    const clock = mock.clock(on);
    sidebar(on, { withClock: false });
    on("session.start", (_, e) => ({ cwd: e.cwd }));
    on("ui.open", () => ({ value: { isPlaced: true } }));
    on("session.cwd", () => ({ value: "/repo" }));
    on("process.run", () => ({
        value: { exitCode: 128, stdout: "", stderr: "", isStdoutTruncated: false, isStderrTruncated: false },
    }));
    on("tool.list", () => ({ value: [] }));
    on("fs.exists", () => ({ value: false }));
    on("skill.prompt", (_, e) => ({ text: e.text }));
    on("session.messages", () => ({
        value: [
            { role: "user", text: "<command-name>/code-modernization:modernize</command-name>", toolUses: [] },
            { role: "user", text: "<command-name>/deploy</command-name>", toolUses: [] },
        ],
    }));

    await $.session.start({ cwd: "/repo", surface: "terminal", isInteractive: true });
    await $.skill.prompt({
        skill: "modernize",
        text: "",
        frontmatter: {},
        source: "plugin",
        pluginName: "code-modernization",
        path: "/plugins/code-modernization/skills/modernize/SKILL.md",
    });
    await $.skill.prompt({
        skill: "deploy",
        text: "",
        frontmatter: {},
        source: "projectSettings",
        path: "/repo/.claude/commands/deploy.md",
    });
    await clock.advance(5000);

    const ui = await $.ui.mount({ ...PANE, surface: "terminal" });
    expect((await ui.find({ type: "Text", text: /^Skills/ }))?.text).toBe("Skills (1)");
    expect((await ui.find({ type: "Text", text: /modernize/ }))?.text).toBe("code-modernization:modernize");
    expect(await ui.find({ type: "Text", text: /^deploy$/ })).toBeUndefined();
    await ui.unmount();
});
