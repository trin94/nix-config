// Plan rate limits: each window's share and the time left until it resets.

import type { SessionRateLimit } from "claude-code";

import type { Ui } from "./ui";

const MINUTE_MS = 60 * 1000;
const HOUR_MS = 60 * MINUTE_MS;
const DAY_MS = 24 * HOUR_MS;
const LABELS: Readonly<Record<string, string>> = { five_hour: "5h", seven_day: "Week", spend_limit: "Spend" };

export type LimitRow = { label: string; percent: number; resets?: string };

/** Time left until the window resets, in its two largest units: `42m`, `3h 12m`, `2d 4h`. */
export function resetText(resetsAt: string, nowMs: number): string | undefined {
    const at = new Date(resetsAt).getTime();
    if (Number.isNaN(at)) return;
    const left = Math.max(0, at - nowMs);
    const days = Math.floor(left / DAY_MS);
    const hours = Math.floor((left % DAY_MS) / HOUR_MS);
    const minutes = Math.floor((left % HOUR_MS) / MINUTE_MS);
    if (days > 0) return `${days}d ${hours}h`;
    if (hours > 0) return `${hours}h ${minutes}m`;
    return `${minutes}m`;
}

export function limitRows(limits: readonly SessionRateLimit[], nowMs: number): LimitRow[] {
    return limits.map((limit) => ({
        label: LABELS[limit.kind] ?? limit.kind,
        percent: limit.percentUsed,
        resets: limit.resetsAt === undefined ? undefined : resetText(limit.resetsAt, nowMs),
    }));
}

/** Amber from 70%, red from 90%: a window's share, where the context section counts tokens. */
export function percentColor(percent: number): "error" | "warning" | undefined {
    if (percent >= 90) return "error";
    if (percent >= 70) return "warning";
}

/** Hidden where no window is reported, as on API-key billing. */
export function Limits({ Box, Text }: Ui, limits: readonly SessionRateLimit[], nowMs: number) {
    const rows = limitRows(limits, nowMs);
    if (rows.length === 0) return null;
    return (
        <Box flexDirection="column">
            <Text bold>Limits</Text>
            {rows.map((limit) => {
                const tone = percentColor(limit.percent);
                return (
                    <Box flexDirection="row" gap={1}>
                        <Text dimColor>{limit.label}</Text>
                        <Text color={tone} dimColor={!tone}>
                            {limit.percent}%
                        </Text>
                        {limit.resets && <Text dimColor>· {limit.resets}</Text>}
                    </Box>
                );
            })}
        </Box>
    );
}
