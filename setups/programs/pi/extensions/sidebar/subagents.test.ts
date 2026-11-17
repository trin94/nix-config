import { expect, test } from "bun:test";
import {
    findNode,
    readHead,
    type SubagentSession,
    subagentRows,
    subagentTree,
    summarize,
    taskLabel,
} from "./subagents";

const RUN = "6fdee22f-9264-48f1-bd28-670d434b440f";

const lines = (...entries: unknown[]) => entries.map((entry) => JSON.stringify(entry)).join("\n");

const head = (parent: string | null, name: string) =>
    lines(
        { type: "session", id: "s", timestamp: "2026-11-17T23:10:20.000Z", parentSession: parent },
        { type: "model_change" },
        { type: "session_info", name },
    );

const reply = (stopReason: string, totalTokens: number) => ({
    type: "message",
    message: { role: "assistant", stopReason, usage: { totalTokens } },
});

const task = (text: string) => ({ type: "message", message: { role: "user", content: [{ type: "text", text }] } });

test("a child session names its agent, launcher, task, context size and whether it finished", () => {
    const start = readHead(
        `${head("/s/main.jsonl", `subagent-ticket-owner-${RUN}-1`)}\n${lines(
            { type: "message", message: { role: "system", content: "prompt" } },
            task("Task: You are the ticket owner for #353.\n\nBrief: …"),
        )}\n{"type":"message","mess`,
    );
    expect(start).toEqual({
        parent: "/s/main.jsonl",
        agent: "ticket-owner",
        startedAt: Date.parse("2026-11-17T23:10:20.000Z"),
        task: "Ticket owner for #353.",
    });
    if (!start) throw new Error("no head");
    const session = summarize(
        "/s/main/run/session.jsonl",
        start,
        // The tail starts mid-line.
        `ge":"cut"}\n${lines(reply("toolUse", 16_235), { type: "message", message: { role: "toolResult" } }, reply("stop", 22_110))}`,
    );
    expect(session).toEqual({ ...start, path: "/s/main/run/session.jsonl", tokens: 22_110, outcome: "done" });
});

test("a task reads from its first line, without the brief's boilerplate", () => {
    expect(taskLabel("Task: You are the Design reviewer. Repo worktree: …")).toBe("Design reviewer. Repo worktree: …");
    expect(taskLabel("\n  Task:   Read-only code   review\nmore")).toBe("Read-only code review");
    expect(taskLabel("you are a fix subagent")).toBe("Fix subagent");
});

test("a head before the task is written has no task yet", () => {
    expect(readHead(head(null, "x"))?.task).toBe("");
});

test("a session mid-turn is open, an errored or aborted one failed", () => {
    const start = readHead(head(null, "x"));
    if (!start) throw new Error("no head");
    const outcome = (stop: string) => summarize("/p", start, lines(reply(stop, 1))).outcome;
    expect(outcome("toolUse")).toBe("open");
    expect(outcome("error")).toBe("failed");
    expect(outcome("aborted")).toBe("failed");
    expect(summarize("/p", start, "").outcome).toBe("open");
});

test("a file without a session header is no child session", () => {
    expect(readHead(lines({ type: "message" }))).toBeUndefined();
});

const session = (path: string, parent: string, fields: Partial<SubagentSession> = {}): SubagentSession => ({
    path,
    parent,
    agent: path,
    task: "",
    startedAt: 0,
    tokens: 0,
    outcome: "done",
    ...fields,
});

test("children nest under the session that launched them, oldest first", () => {
    const tree = subagentTree(
        [
            session("b", "main", { startedAt: 2 }),
            session("a", "main", { startedAt: 1 }),
            session("a1", "a"),
            session("other", "elsewhere"),
        ],
        "main",
        () => true,
    );
    expect(tree.map((node) => [node.agent, node.children.map((child) => child.agent)])).toEqual([
        ["a", ["a1"]],
        ["b", []],
    ]);
});

test("an open session runs while its top-level run is live, and was cut off once it is not", () => {
    const sessions = [session("a", "main", { outcome: "open" }), session("a1", "a", { outcome: "open" })];
    const live = subagentTree(sessions, "main", (top) => top.path === "a");
    expect([live[0]?.state, live[0]?.children[0]?.state]).toEqual(["running", "running"]);
    const ended = subagentTree(sessions, "main", () => false);
    expect([ended[0]?.state, ended[0]?.children[0]?.state]).toEqual(["failed", "failed"]);
});

test("rows draw the tree and fold a finished subtree into its top row, unless opened", () => {
    const sessions = [
        session("owner", "main", { outcome: "open", startedAt: 1 }),
        session("worker", "owner"),
        session("reviewer", "owner", { outcome: "open", startedAt: 1 }),
        session("researcher", "main", { startedAt: 2 }),
        session("scout", "researcher"),
        session("deep", "scout"),
    ];
    const tree = subagentTree(sessions, "main", () => true);
    const draw = (folds: Map<string, boolean>) =>
        subagentRows(tree, folds).map(
            (row) => `${row.prefix}${row.node.agent}${row.hidden ? ` +${row.hidden}` : ""}|${row.continuation}`,
        );
    expect(draw(new Map())).toEqual([
        "├─ owner|│  ",
        "│  ├─ worker|│  │  ",
        "│  └─ reviewer|│     ",
        "└─ researcher +2|   ",
    ]);
    expect(
        draw(
            new Map([
                ["owner", false],
                ["researcher", true],
            ]),
        ),
    ).toEqual(["├─ owner +2|│  ", "└─ researcher|   ", "   └─ scout +1|      "]);
    expect(findNode(tree, "deep")?.agent).toBe("deep");
});
