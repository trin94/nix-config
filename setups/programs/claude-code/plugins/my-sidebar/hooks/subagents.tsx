// Every subagent in this session's tree with its context size, as in OpenCode's my-subagent-context.
// A click on one puts its conversation in the main view.

import type { AgentInfo, EngineInterface } from "claude-code";
import { atom, read, update } from "claude-code";

import type { AgentSnapshot, Folds } from "../types";
import type { Ui } from "./ui";

const PERCENT_FROM_TOKENS = 200_000;
const WARNING_TOKENS = 125_000;
const ERROR_TOKENS = 225_000;

// Kept across reloads until the session ends.
const folds = atom({ plugin: "my-sidebar", key: "folds" } as const, {}, { shape: "folds-1" });
const seen = atom({ plugin: "my-sidebar", key: "seen" } as const, {}, { shape: "seen-1" });

function snapshot(agent: AgentInfo): AgentSnapshot {
    const { id, parentId, description, type, status, startTime, tokenCount, contextWindowSize } = agent;
    return { id, parentId, description, type, status, startTime, tokenCount, contextWindowSize };
}

/** `past` with each listed agent's current values. */
export function remember(
    past: Readonly<Record<string, AgentSnapshot>>,
    live: readonly AgentInfo[],
): Record<string, AgentSnapshot> {
    return { ...past, ...Object.fromEntries(live.map((agent) => [agent.id, snapshot(agent)])) };
}

/** The listed agents, then the remembered ones Claude Code dropped, as finished. */
export function roster(live: readonly AgentInfo[], past: Readonly<Record<string, AgentSnapshot>>): AgentSnapshot[] {
    const listed = new Set(live.map((agent) => agent.id));
    const gone = Object.values(past)
        .filter((agent) => !listed.has(agent.id))
        .map((agent) => ({ ...agent, status: isActive(agent) ? "completed" : agent.status, isGone: true }));
    return [...live.map(snapshot), ...gone];
}

export type Row = {
    agent: AgentSnapshot;
    prefix: string;
    /** Descendants folded away under this row. */
    hidden: number;
    expanded: boolean;
    hasChildren: boolean;
};

export const isActive = (agent: AgentSnapshot) =>
    agent.status === "pending" || agent.status === "running" || agent.status === "waiting";

/**
 * The agents in depth-first order under the main loop, with tree-drawing prefixes.
 * A subtree with no active agent folds into its top row unless `overrides` says otherwise.
 */
export function tree(agents: readonly AgentSnapshot[], overrides: Readonly<Folds>): Row[] {
    const children = new Map<string | undefined, AgentSnapshot[]>();
    for (const agent of agents) {
        children.set(agent.parentId, [...(children.get(agent.parentId) ?? []), agent]);
    }
    const descendants = (id: string): AgentSnapshot[] =>
        (children.get(id) ?? []).flatMap((child) => [child, ...descendants(child.id)]);

    const walk = (parentId: string | undefined, indent: string): Row[] => {
        const group = (children.get(parentId) ?? []).toSorted((a, b) => a.startTime - b.startTime);
        return group.flatMap((agent, index) => {
            const last = index === group.length - 1;
            const prefix = indent + (last ? "└─ " : "├─ ");
            const hidden = descendants(agent.id);
            const hasChildren = hidden.length > 0;
            const expanded = overrides[agent.id] ?? [agent, ...hidden].some(isActive);
            if (hasChildren && !expanded) {
                return [{ agent, prefix, hidden: hidden.length, expanded, hasChildren }];
            }
            return [
                { agent, prefix, hidden: 0, expanded, hasChildren },
                ...walk(agent.id, indent + (last ? "   " : "│  ")),
            ];
        });
    };
    return walk(undefined, "");
}

export function formatTokens(tokens: number): string {
    if (tokens >= 999_950) return `${(tokens / 1_000_000).toFixed(1)}M`;
    if (tokens >= 1000) return `${(tokens / 1000).toFixed(1)}K`;
    return String(tokens);
}

export function usageText(agent: AgentSnapshot): string | undefined {
    if (agent.tokenCount <= 0) return;
    const tokens = formatTokens(agent.tokenCount);
    if (!agent.contextWindowSize || agent.tokenCount < PERCENT_FROM_TOKENS) return tokens;
    return `${tokens} ${Math.round((agent.tokenCount / agent.contextWindowSize) * 100)}%`;
}

export function usageColor(tokens: number): "error" | "warning" | undefined {
    if (tokens >= ERROR_TOKENS) return "error";
    if (tokens >= WARNING_TOKENS) return "warning";
}

/** Keeps every subagent's last listing, so a finished one stays in the bar after Claude Code drops it. */
export async function rememberAgents($: EngineInterface): Promise<void> {
    try {
        const [live, past] = await Promise.all([$.agent.list(), read($, seen)]);
        const next = remember(past, live);
        if (JSON.stringify(next) !== JSON.stringify(past)) await update($, seen, () => next);
    } catch {
        // The session going away; the next tick tries again.
    }
}

/** The section, read fresh on each draw: token counts move without an event. */
export async function Subagents(ui: Ui, $: EngineInterface, viewed: string | undefined) {
    const { Box, Text, Button } = ui;
    const [live, past, opened] = await Promise.all([$.agent.list(), read($, seen), read($, folds)]);
    const rows = tree(roster(live, past), opened);
    if (rows.length === 0) return null;

    return (
        <Box flexDirection="column">
            <Box flexDirection="row" gap={1}>
                <Box flexGrow={1}>
                    <Text bold>Subagents</Text>
                </Box>
                {viewed && (
                    <Button key="view-main" plain onPress={() => $.ui.view({})}>
                        <Text color="suggestion">← Main conversation</Text>
                    </Button>
                )}
            </Box>
            {rows.map((row) => {
                const dim = !isActive(row.agent);
                const usageLine = usageText(row.agent);
                const color = usageColor(row.agent.tokenCount);
                const isViewed = viewed === row.agent.id;
                const label = row.agent.description || row.agent.type;
                const toggle = () => update($, folds, (current) => ({ ...current, [row.agent.id]: !row.expanded }));
                // The tasks list's switch: the agent's transcript in the main view, again for the chat.
                const view = async () => {
                    const result = await $.ui.view(isViewed ? {} : { agentId: row.agent.id });
                    if (result.deny) $.ui.toast(result.deny);
                };
                return (
                    <Box flexDirection="row" gap={1}>
                        <Box flexDirection="row" flexGrow={1} minWidth={0}>
                            <Text dimColor={dim} wrap="clip">
                                {row.prefix}
                            </Text>
                            {row.agent.isGone ? (
                                <Text dimColor wrap="truncate-end">
                                    {label}
                                </Text>
                            ) : (
                                <Button key={`view-${row.agent.id}`} plain dimColor={dim && !isViewed} onPress={view}>
                                    <Text bold={isViewed} wrap="truncate-end">
                                        {label}
                                    </Text>
                                </Button>
                            )}
                        </Box>
                        {row.hasChildren && (
                            <Button key={row.agent.id} plain dimColor onPress={toggle}>
                                {row.expanded ? "−" : `+${row.hidden}`}
                            </Button>
                        )}
                        {usageLine && (
                            <Text color={color} dimColor={dim && !color}>
                                {usageLine}
                            </Text>
                        )}
                    </Box>
                );
            })}
        </Box>
    );
}
