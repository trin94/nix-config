// The main conversation's context window and the session's cost estimate.

import type { SessionContextUsage, SessionCost, SessionUsage } from "claude-code";

import { formatTokens, usageColor } from "./subagents";
import type { Ui } from "./ui";

export function contextRows(context: SessionContextUsage): string[] {
    if (context.tokens === undefined) return [];
    return [
        `${formatTokens(context.tokens)} / ${formatTokens(context.window)} tokens`,
        `${context.percent ?? 0}% used`,
    ];
}

/** `$1.23 spent`, marked `~` when a model had no known price. An API-price estimate, not a bill. */
export function costText(cost: SessionCost | undefined): string | undefined {
    if (!cost) return;
    return `${cost.hasUnknownPrice ? "~" : ""}$${cost.usd.toFixed(2)} spent`;
}

/** Hidden until the first response says how full the window is. */
export function Context({ Box, Text }: Ui, usage: SessionUsage) {
    const [tokens, share] = contextRows(usage.context);
    if (tokens === undefined) return null;
    // The subagents' thresholds, so one size reads the same colour everywhere in the bar.
    const tone = usageColor(usage.context.tokens ?? 0);
    const cost = costText(usage.cost);
    return (
        <Box flexDirection="column">
            <Text bold>Context</Text>
            <Text color={tone} dimColor={!tone}>
                {tokens}
            </Text>
            <Text color={tone} dimColor={!tone}>
                {share}
            </Text>
            {cost && <Text dimColor>{cost}</Text>}
        </Box>
    );
}
