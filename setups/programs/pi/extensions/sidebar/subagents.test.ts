import { expect, test } from "bun:test";
import { type SubagentSession, subagentRows, subagentTree, summarize } from "./subagents";

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

test("a child session names its agent, launcher, context size and whether it finished", () => {
    const session = summarize(
        "/s/main/run/session.jsonl",
        // The head ends mid-line, where the system prompt was cut off.
        `${head("/s/main.jsonl", `subagent-ticket-owner-${RUN}-1`)}\n{"type":"message","mess`,
        `ge":"cut"}\n${lines(reply("toolUse", 16_235), { type: "message", message: { role: "toolResult" } }, reply("stop", 22_110))}`,
    );
    expect(session).toEqual({
        path: "/s/main/run/session.jsonl",
        parent: "/s/main.jsonl",
        agent: "ticket-owner",
        startedAt: Date.parse("2026-11-17T23:10:20.000Z"),
        tokens: 22_110,
        outcome: "done",
    });
});

test("a session mid-turn is open, an errored or aborted one failed", () => {
    const outcome = (stop: string) => summarize("/p", head(null, "x"), lines(reply(stop, 1)))?.outcome;
    expect(outcome("toolUse")).toBe("open");
    expect(outcome("error")).toBe("failed");
    expect(outcome("aborted")).toBe("failed");
    expect(summarize("/p", head(null, "x"), "")?.outcome).toBe("open");
});

test("a file without a session header is no child session", () => {
    expect(summarize("/p", lines({ type: "message" }), "")).toBeUndefined();
});

const session = (path: string, parent: string, fields: Partial<SubagentSession> = {}): SubagentSession => ({
    path,
    parent,
    agent: path,
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

test("rows draw the tree and fold a finished subtree into its top row", () => {
    const sessions = [
        session("owner", "main", { outcome: "open", startedAt: 1 }),
        session("worker", "owner"),
        session("reviewer", "owner", { outcome: "open", startedAt: 1 }),
        session("researcher", "main", { startedAt: 2 }),
        session("scout", "researcher"),
        session("deep", "scout"),
    ];
    const rows = subagentRows(subagentTree(sessions, "main", () => true));
    expect(rows.map((row) => `${row.prefix}${row.agent}${row.hidden ? ` +${row.hidden}` : ""}`)).toEqual([
        "├─ owner",
        "│  ├─ worker",
        "│  └─ reviewer",
        "└─ researcher +2",
    ]);
});
