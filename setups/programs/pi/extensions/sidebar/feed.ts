// Feeds the Subagents section. The tree comes from the session files: pi-subagents writes each child's session
// under its launcher's directory with the launcher's file as `parentSession`, nested children included, which
// its status does not report. Whether a top-level run is still live comes from pi-subagents' in-process RPC
// for background runs, and from the open `subagent` tool call for foreground ones.

import { open, readdir } from "node:fs/promises";
import { basename, join, relative, sep } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { type SubagentNode, type SubagentSession, subagentTree, summarize } from "./subagents";

// The header and name sit in the first lines, before the system prompt; the last response fits in the tail.
const HEAD_BYTES = 8 * 1024;
const TAIL_BYTES = 64 * 1024;
// pi-subagents fires its events in bursts; it asks hosts to coalesce them.
const STATUS_COALESCE_MS = 250;
const CHANGE_EVENTS = [
    "subagent:jobs-changed",
    "subagent:async-started",
    "subagent:child-status",
    "subagent:async-complete",
    "subagent:process-terminal",
];
const LIVE_STATES = new Set(["queued", "pending", "running"]);

function isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === "object" && value !== null;
}

async function readEdges(path: string): Promise<{ head: string; tail: string }> {
    const file = await open(path, "r");
    try {
        const { size } = await file.stat();
        const head = Buffer.alloc(Math.min(size, HEAD_BYTES));
        await file.read(head, 0, head.length, 0);
        const tailStart = Math.max(0, size - TAIL_BYTES);
        const tail = Buffer.alloc(size - tailStart);
        await file.read(tail, 0, tail.length, tailStart);
        return { head: head.toString("utf8"), tail: tail.toString("utf8") };
    } finally {
        await file.close();
    }
}

/** Every child session under the main session's directory, at any depth. */
async function childSessions(dir: string): Promise<SubagentSession[]> {
    let files: string[];
    try {
        files = await readdir(dir, { recursive: true });
    } catch {
        return [];
    }
    const sessions = await Promise.all(
        files
            .filter((file) => basename(file) === "session.jsonl")
            .map(async (file) => {
                const path = join(dir, file);
                try {
                    const { head, tail } = await readEdges(path);
                    return summarize(path, head, tail);
                } catch {
                    return undefined;
                }
            }),
    );
    return sessions.filter((session) => session !== undefined);
}

/** Run ids of the background runs pi-subagents' status reports as live. */
function liveRuns(reply: unknown): Set<string> | undefined {
    if (!isRecord(reply) || reply.success !== true || !isRecord(reply.data)) return;
    const snapshot = reply.data.asyncSnapshot;
    const runs = isRecord(snapshot) && Array.isArray(snapshot.runs) ? snapshot.runs : [];
    const live = new Set<string>();
    for (const run of runs) {
        if (isRecord(run) && typeof run.id === "string" && LIVE_STATES.has(String(run.state))) live.add(run.id);
    }
    return live;
}

export function subagentFeed(pi: ExtensionAPI, changed: () => void) {
    let nodes: SubagentNode[] = [];
    // Unknown until the first status reply; open sessions count as running till then.
    let background: Set<string> | undefined;
    const foreground = new Map<string, string>();
    let requests = 0;
    let statusTimer: ReturnType<typeof setTimeout> | undefined;
    let scanning = false;

    const requestStatus = () => {
        const requestId = `sidebar-${requests++}`;
        const stop = pi.events.on(`subagents:rpc:v1:reply:${requestId}`, (reply) => {
            stop();
            const live = liveRuns(reply);
            if (!live) return;
            background = live;
            changed();
        });
        pi.events.emit("subagents:rpc:v1:request", { version: 1, requestId, method: "status" });
    };
    const scheduleStatus = () => {
        if (statusTimer) return;
        statusTimer = setTimeout(() => {
            statusTimer = undefined;
            requestStatus();
        }, STATUS_COALESCE_MS);
    };

    pi.events.on("subagents:rpc:v1:ready", scheduleStatus);
    for (const name of CHANGE_EVENTS) pi.events.on(name, scheduleStatus);
    pi.on("session_start", () => {
        foreground.clear();
        background = undefined;
        nodes = [];
        scheduleStatus();
    });

    // A foreground run is live while its tool call is open; its id arrives with the first progress update.
    pi.on("tool_execution_update", (event) => {
        const runId = event.toolName === "subagent" ? event.partialResult?.details?.runId : undefined;
        if (typeof runId === "string") foreground.set(event.toolCallId, runId);
    });
    pi.on("tool_execution_end", (event) => {
        if (foreground.delete(event.toolCallId)) changed();
    });

    return {
        nodes: (): readonly SubagentNode[] => nodes,

        /** Rereads the child sessions of `sessionFile`; none without one, as with `--no-session`. */
        async refresh(sessionFile: string | undefined): Promise<void> {
            if (scanning) return;
            scanning = true;
            try {
                if (!sessionFile) {
                    nodes = [];
                    return;
                }
                const dir = sessionFile.replace(/\.jsonl$/, "");
                const sessions = await childSessions(dir);
                const running = new Set(foreground.values());
                // A top-level child lives in `<dir>/<run id>/…`.
                const isLive = (top: SubagentSession) => {
                    const runId = relative(dir, top.path).split(sep)[0] ?? "";
                    return background === undefined || background.has(runId) || running.has(runId);
                };
                nodes = subagentTree(sessions, sessionFile, isLive);
            } finally {
                scanning = false;
            }
            changed();
        },
    };
}
