// Git metrics, ported from OpenCode's my-vcs-status/vcs.ts.
//
// Two independent numbers:
//   branch = merge-base(<default branch>, HEAD) -> HEAD  (committed work on this branch)
//   dirty  = HEAD -> index + working tree                (tracked, not committed yet)

import type { GitStatus, Stats } from "../types";
import type { Ui } from "./ui";

export type StatusSegment = {
    label: string;
    additions: number;
    deletions: number;
};

/** Trimmed stdout, or undefined when git fails (not a repo, unknown ref, ...). */
export type GitRunner = (args: string[]) => Promise<string | undefined>;

const FALLBACK_BASE = "main";
const BASE_CANDIDATES = ["main", "master"];

function emptyStats(): Stats {
    return { files: 0, additions: 0, deletions: 0 };
}

/** Sum `git diff --numstat` output. Binary files report "-" and count as changed files only. */
export function parseNumstat(output: string): Stats {
    const stats = emptyStats();
    for (const line of output.split("\n")) {
        if (line.trim() === "") continue;
        const [additions = "", deletions = ""] = line.split("\t");
        stats.files += 1;
        const added = Number.parseInt(additions, 10);
        const deleted = Number.parseInt(deletions, 10);
        if (Number.isInteger(added)) stats.additions += added;
        if (Number.isInteger(deleted)) stats.deletions += deleted;
    }
    return stats;
}

function hasLines(stats: Stats): boolean {
    return stats.additions > 0 || stats.deletions > 0;
}

function fileCount(count: number): string {
    return `${count} ${count === 1 ? "file" : "files"}`;
}

/** One line each, kept separate so the sidebar can colour additions and deletions on its own. */
export function statusSegments(status: GitStatus): StatusSegment[] {
    const segments: StatusSegment[] = [];
    const { branch, dirty } = status;
    if (branch.files > 0) {
        // Binary-only changes carry no line counts, so the file count is all that is left to show.
        const label = `Since ${status.base}:`;
        segments.push({
            label: hasLines(branch) ? label : `${label} ${fileCount(branch.files)}`,
            additions: branch.additions,
            deletions: branch.deletions,
        });
    }
    if (dirty.files > 0) {
        segments.push({
            label: `Uncommitted: ${fileCount(dirty.files)}`,
            additions: dirty.additions,
            deletions: dirty.deletions,
        });
    }
    return segments;
}

/** Local branch first so a stale remote does not widen the delta, remote as the fallback. */
async function resolveRef(run: GitRunner, name: string): Promise<string | undefined> {
    for (const ref of [`refs/heads/${name}`, `refs/remotes/origin/${name}`]) {
        if ((await run(["rev-parse", "--verify", "--quiet", ref])) !== undefined) return ref;
    }
    return undefined;
}

/** The branch point: whatever the remote calls default, else the first branch that exists. */
async function detectBase(run: GitRunner): Promise<{ label: string; ref: string }> {
    const remoteHead = await run(["symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD"]);
    const names = remoteHead ? [remoteHead.replace(/^origin\//, "")] : BASE_CANDIDATES;
    for (const name of names) {
        const ref = await resolveRef(run, name);
        if (ref) return { label: name, ref };
    }
    return { label: FALLBACK_BASE, ref: FALLBACK_BASE };
}

async function collectBranch(run: GitRunner, ref: string): Promise<Stats> {
    const mergeBase = await run(["merge-base", ref, "HEAD"]);
    if (!mergeBase) return emptyStats();
    const numstat = await run(["diff", "--numstat", `${mergeBase}..HEAD`]);
    return numstat === undefined ? emptyStats() : parseNumstat(numstat);
}

async function collectDirty(run: GitRunner): Promise<Stats> {
    const numstat = await run(["diff", "--numstat", "HEAD"]);
    return numstat === undefined ? emptyStats() : parseNumstat(numstat);
}

/** The branch, or the short commit when detached. */
async function collectHead(run: GitRunner): Promise<string> {
    const branch = await run(["branch", "--show-current"]);
    if (branch) return branch;
    return (await run(["rev-parse", "--short", "HEAD"])) ?? "no commits";
}

/** Null outside a repository. */
export async function collectStatus(run: GitRunner): Promise<GitStatus | null> {
    if ((await run(["rev-parse", "--git-dir"])) === undefined) return null;
    const base = await detectBase(run);
    const [head, branch, dirty] = await Promise.all([
        collectHead(run),
        collectBranch(run, base.ref),
        collectDirty(run),
    ]);
    return { head, base: base.label, branch, dirty };
}

/** Hidden outside a repository. */
export function Git({ Box, Text }: Ui, status: GitStatus | null) {
    if (!status) return null;
    return (
        <Box flexDirection="column">
            <Text bold>Git</Text>
            <Text dimColor wrap="truncate-end">
                {status.head}
            </Text>
            {statusSegments(status).map((segment) => (
                <Box flexDirection="row" gap={1}>
                    <Text dimColor>{segment.label}</Text>
                    {segment.additions > 0 && <Text color="success">+{segment.additions}</Text>}
                    {segment.deletions > 0 && <Text color="error">-{segment.deletions}</Text>}
                </Box>
            ))}
        </Box>
    );
}
