// Git metrics for the OpenCode sidebar.
//
// Two independent numbers, deliberately not OpenCode's own diff counters:
//   branch = merge-base(<default branch>, HEAD) -> HEAD  (committed work on this branch)
//   dirty  = HEAD -> index + working tree                (tracked, not committed yet)

import { execFile } from "node:child_process";

export type Stats = {
    files: number;
    additions: number;
    deletions: number;
};

export type BaseBranch = {
    /** What to call it on screen. */
    label: string;
    /** A ref that actually resolves, which the label may not: a clone need not carry the branch locally. */
    ref: string;
};

export type VcsStatus = {
    base: string;
    branch: Stats;
    dirty: Stats;
};

export type StatusSegment = {
    label: string;
    additions: number;
    deletions: number;
};

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
export function statusSegments(status: VcsStatus): StatusSegment[] {
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

/** Trimmed stdout, or undefined when git fails (not a repo, unknown ref, ...). */
export function gitRunner(cwd: string): GitRunner {
    return (args) =>
        new Promise((resolve) => {
            execFile("git", ["--no-optional-locks", ...args], { cwd }, (error, stdout) => {
                resolve(error ? undefined : stdout.trim());
            });
        });
}

/** Local branch first so a stale remote does not widen the delta, remote as the fallback. */
async function resolveRef(run: GitRunner, name: string): Promise<string | undefined> {
    for (const ref of [`refs/heads/${name}`, `refs/remotes/origin/${name}`]) {
        if ((await run(["rev-parse", "--verify", "--quiet", ref])) !== undefined) return ref;
    }
    return undefined;
}

/** The branch point: whatever the remote calls default, else the first branch that exists. */
export async function detectBase(run: GitRunner): Promise<BaseBranch> {
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

/** Undefined outside a repository. Branch and dirty stats are gathered concurrently. */
export async function collectStatus(run: GitRunner): Promise<VcsStatus | undefined> {
    if ((await run(["rev-parse", "--git-dir"])) === undefined) return undefined;
    const base = await detectBase(run);
    const [branch, dirty] = await Promise.all([collectBranch(run, base.ref), collectDirty(run)]);
    return { base: base.label, branch, dirty };
}
