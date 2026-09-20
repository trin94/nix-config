import assert from "node:assert/strict";
import { execFile } from "node:child_process";
import { mkdir, mkdtemp, readFile, rm, symlink, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, test } from "node:test";
import { promisify, stripVTControlCharacters } from "node:util";
import { SessionManager, Theme, type ThemeColor } from "@earendil-works/pi-coding-agent";
import { visibleWidth } from "@earendil-works/pi-tui";
import { normalizeConfig } from "pi-footer/src/config.ts";
import { EMPTY_GIT_INFO } from "pi-footer/src/git.ts";
import { collectSessionMetrics, collectTurnMetrics } from "pi-footer/src/metrics.ts";
import { renderStatuslines } from "pi-footer/src/render.ts";
import type { StatuslineData } from "pi-footer/src/types.ts";
import { WidgetStore } from "pi-footer/src/widgets/store.ts";
import { collectStatus, gitRunner } from "../../opencode/vcs-status/vcs.ts";
import { registerSessionStatus, type StatusAPI, type StatusContext, type StatusEvent } from "./index.ts";
import { loadedSkills } from "./skills.ts";

const execute = promisify(execFile);
const roots: string[] = [];
const stops: (() => Promise<void>)[] = [];
const themeModule = await import(
    new URL("./modes/interactive/theme/theme.js", import.meta.resolve("@earendil-works/pi-coding-agent")).href
);
function getThemeByName(name: string): Theme {
    const theme: unknown = themeModule.getThemeByName(name);
    assert.ok(theme instanceof Theme, `theme ${name} exists`);
    return theme;
}
const theme = getThemeByName("dark");
const plain = stripVTControlCharacters;

afterEach(async () => {
    for (const stop of stops.splice(0)) await stop();
    for (const root of roots.splice(0)) await rm(root, { recursive: true, force: true });
});

async function temporaryDirectory() {
    const root = await mkdtemp(join(tmpdir(), "pi-status-test-"));
    roots.push(root);
    return root;
}

function readSkill(session: SessionManager, path: string, { error = false, content = "skill instructions" } = {}) {
    const id = `read-${session.getEntries().length}`;
    session.appendMessage({
        role: "assistant",
        content: [{ type: "toolCall", id, name: "read", arguments: { path } }],
        api: "openai-responses",
        provider: "openai",
        model: "test",
        stopReason: "toolUse",
        usage: {
            input: 0,
            output: 0,
            cacheRead: 0,
            cacheWrite: 0,
            totalTokens: 0,
            cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
        },
        timestamp: Date.now(),
    });
    session.appendMessage({
        role: "toolResult",
        toolName: "read",
        toolCallId: id,
        isError: error,
        content: [{ type: "text", text: content }],
        timestamp: Date.now(),
    });
}

async function repository() {
    const cwd = await temporaryDirectory();
    const git = (...args: string[]) => execute("git", args, { cwd });
    await git("init", "-q", "-b", "main");
    await git("config", "user.email", "test@example.invalid");
    await git("config", "user.name", "Test");
    await git("config", "commit.gpgsign", "false");
    await writeFile(join(cwd, "tracked.txt"), "base\n");
    await git("add", ".");
    await git("commit", "-qm", "base");
    await git("switch", "-qc", "feature");
    await writeFile(join(cwd, "tracked.txt"), "base\nbranch\n");
    await git("commit", "-qam", "branch work");
    return { cwd, git };
}

function matchesEvent<K extends StatusEvent["type"]>(
    event: StatusEvent,
    name: K,
): event is Extract<StatusEvent, { type: K }> {
    return event.type === name;
}

function harness(cwd: string, options: { mode?: StatusContext["mode"]; exec?: StatusAPI["exec"] } = {}) {
    const handlers: ((event: StatusEvent) => void)[] = [];
    const statuses = new Map<string, string>();
    const widgets = new Map<string, string[]>();
    const session = SessionManager.inMemory(cwd);
    const ctx = {
        cwd,
        mode: options.mode ?? "tui",
        hasUI: true,
        sessionManager: session,
        ui: {
            theme,
            setStatus(key: string, value: string | undefined) {
                value === undefined ? statuses.delete(key) : statuses.set(key, value);
            },
            setWidget(key: string, value: string[] | undefined) {
                value === undefined ? widgets.delete(key) : widgets.set(key, value);
            },
        },
    };
    registerSessionStatus({
        on(name, handler) {
            handlers.push((event) => {
                if (matchesEvent(event, name)) return handler(event, ctx);
            });
        },
        getCommands: () => [],
        exec:
            options.exec ??
            (async (command, args, { cwd, timeout, signal } = {}) => {
                try {
                    const result = await execute(command, args, { cwd, timeout, signal });
                    return { ...result, code: 0, killed: false };
                } catch (error) {
                    return {
                        stdout:
                            error instanceof Error && "stdout" in error && typeof error.stdout === "string"
                                ? error.stdout
                                : "",
                        stderr:
                            error instanceof Error && "stderr" in error && typeof error.stderr === "string"
                                ? error.stderr
                                : "",
                        code: 1,
                        killed: error instanceof Error && "killed" in error && error.killed === true,
                    };
                }
            }),
    });
    const emit = async (event: StatusEvent) => {
        for (const handler of handlers) await handler(event);
    };
    stops.push(() => emit({ type: "session_shutdown", reason: "quit" }));
    return { ctx, session, statuses, widgets, emit };
}

async function waitFor(predicate: () => boolean, timeout = 2000) {
    const deadline = Date.now() + timeout;
    while (!predicate()) {
        assert.ok(Date.now() < deadline, "timed out waiting for status update");
        await new Promise((resolve) => setTimeout(resolve, 10));
    }
}

function skillText(h: ReturnType<typeof harness>) {
    const status = h.statuses.get("dotfiles-loaded-skills");
    assert.ok(status, "skills footer status exists even when no skills are loaded");
    assert.equal(h.widgets.size, 0, "skills must not appear above the editor");
    return plain(status);
}

test("tracks successful loads, manual skill expansion and first-use order, not availability", () => {
    const session = SessionManager.inMemory("/project");
    const catalog = [
        { name: "first", filePath: "/project/first/SKILL.md" },
        { name: "unused", filePath: "/project/unused/SKILL.md" },
    ];
    assert.deepEqual(loadedSkills(session.getBranch(), catalog, "/project"), []);
    readSkill(session, "@first/SKILL.md", { error: true });
    readSkill(session, "README.md");
    readSkill(session, "malformed/SKILL.md", { content: "---\nname: [broken\n---\nBody" });
    assert.deepEqual(loadedSkills(session.getBranch(), catalog, "/project"), []);
    readSkill(session, "first/SKILL.md");
    session.appendMessage({
        role: "user",
        content: '<skill name="manual" location="/other/SKILL.md">\nInstructions\n</skill>',
        timestamp: Date.now(),
    });
    readSkill(session, "/project/first/SKILL.md");
    assert.deepEqual(loadedSkills(session.getBranch(), catalog, "/project"), ["first", "manual"]);
});

test("recognizes symlinked skill paths and preserves a removed skill's actual name", async () => {
    const cwd = await temporaryDirectory();
    await mkdir(join(cwd, "real"));
    await writeFile(join(cwd, "real/SKILL.md"), "---\nname: named-skill\n---\nBody\n");
    await symlink(join(cwd, "real"), join(cwd, "linked"));
    const session = SessionManager.inMemory(cwd);
    readSkill(session, "real/SKILL.md");
    readSkill(session, "/gone/different-folder/SKILL.md", {
        content: "---\nname: retired-name\ndescription: old skill\n---\nInstructions",
    });
    assert.deepEqual(
        loadedSkills(session.getBranch(), [{ name: "named-skill", filePath: join(cwd, "linked/SKILL.md") }], cwd),
        ["named-skill", "retired-name"],
    );
});

test("reconstructs skills after compaction and follows only the selected session branch", () => {
    const session = SessionManager.inMemory("/project");
    const root = session.appendMessage({ role: "user", content: "start", timestamp: Date.now() });
    readSkill(session, "/project/one/SKILL.md", { content: "---\nname: one\n---\nInstructions" });
    const leaf = session.getLeafId();
    assert.ok(leaf);
    session.appendCompaction("summary", leaf, 5000);
    assert.deepEqual(loadedSkills(session.getBranch(), [], "/project"), ["one"]);
    session.branch(root);
    readSkill(session, "/project/two/SKILL.md", { content: "---\nname: two\n---\nInstructions" });
    assert.deepEqual(loadedSkills(session.getBranch(), [], "/project"), ["two"]);
});

test("uses OpenCode's merge-base and HEAD metrics; staged/unstaged changes count once, untracked excluded", async () => {
    const { cwd, git } = await repository();
    await writeFile(join(cwd, "tracked.txt"), "base\nbranch\npending\n");
    await writeFile(join(cwd, "staged.txt"), "staged\n");
    await git("add", "staged.txt");
    await writeFile(join(cwd, "staged.txt"), "staged\nunstaged too\n");
    await writeFile(join(cwd, "untracked.txt"), "not counted\n");
    const status = await collectStatus(gitRunner(cwd));
    assert.deepEqual(status, {
        base: "main",
        branch: { files: 1, additions: 1, deletions: 0 },
        dirty: { files: 2, additions: 3, deletions: 0 },
    });
    const h = harness(cwd);
    await h.emit({ type: "session_start", reason: "startup" });
    await waitFor(() => plain(h.statuses.get("dotfiles-git-dirty") ?? "").includes("2 files +3 -0"));
    assert.equal(
        h.statuses.get("dotfiles-git-branch-diff"),
        theme.fg("dim", `Since main: 1 file ${theme.fg("toolDiffAdded", "+1")} ${theme.fg("toolDiffRemoved", "-0")}`),
    );
});

test("shows clean zeros, refreshes edits and external changes, clears on shutdown", { timeout: 10000 }, async () => {
    const { cwd } = await repository();
    const h = harness(cwd);
    await h.emit({ type: "session_start", reason: "startup" });
    await waitFor(() => plain(h.statuses.get("dotfiles-git-dirty") ?? "").includes("0 files +0 -0"));
    assert.equal(skillText(h), "Skills (0): none loaded");
    await writeFile(join(cwd, "tracked.txt"), "base\nbranch\nedit\n");
    await h.emit({ type: "tool_execution_end", toolName: "edit", toolCallId: "edit-1", result: {}, isError: false });
    await waitFor(() => plain(h.statuses.get("dotfiles-git-dirty") ?? "").includes("1 file +1 -0"));
    await writeFile(join(cwd, "tracked.txt"), "base\nbranch\nedit\nexternal\n");
    await waitFor(() => plain(h.statuses.get("dotfiles-git-dirty") ?? "").includes("1 file +2 -0"), 6500);
    await h.emit({ type: "session_shutdown", reason: "quit" });
    assert.equal(h.statuses.size, 0);
    assert.equal(h.widgets.size, 0);
});

test("publishes restored skills in the footer, updates from reads and resets on tree navigation", async () => {
    const cwd = await temporaryDirectory();
    const h = harness(cwd);
    const root = h.session.appendMessage({ role: "user", content: "start", timestamp: Date.now() });
    const names = ["reporting", "ghostwriter", "code-review", "commit-conventions"];
    for (const name of names)
        readSkill(h.session, `${name}/SKILL.md`, { content: `---\nname: ${name}\n---\nInstructions` });
    await h.emit({ type: "session_start", reason: "startup" });
    assert.equal(skillText(h), `Skills (4): ${names.join(" · ")}`);
    h.session.branch(root);
    await h.emit({ type: "session_tree", newLeafId: root, oldLeafId: null });
    assert.equal(skillText(h), "Skills (0): none loaded");
    readSkill(h.session, "new/SKILL.md", { content: "---\nname: new\n---\nInstructions" });
    await h.emit({
        type: "message_end",
        message: {
            role: "toolResult",
            toolName: "read",
            toolCallId: "read-new",
            content: [],
            isError: false,
            timestamp: Date.now(),
        },
    });
    assert.equal(skillText(h), "Skills (1): new");
});

test("stays inert in headless mode and ignores an old Git completion after shutdown", async () => {
    const cwd = await temporaryDirectory();
    const headless = harness(cwd, { mode: "print", exec: () => assert.fail("headless UI ran git") });
    await headless.emit({ type: "session_start", reason: "startup" });
    assert.equal(headless.widgets.size, 0);
    assert.equal(headless.statuses.size, 0);
    type ExecResult = Awaited<ReturnType<StatusAPI["exec"]>>;
    const pending: { resolve?: (result: ExecResult) => void } = {};
    const h = harness(cwd, {
        exec: () =>
            new Promise<ExecResult>((resolve) => {
                pending.resolve = resolve;
            }),
    });
    await h.emit({ type: "session_start", reason: "startup" });
    await h.emit({ type: "session_shutdown", reason: "quit" });
    assert.ok(pending.resolve, "Git execution started before shutdown");
    pending.resolve({ code: 1, stdout: "", stderr: "", killed: false });
    await new Promise((resolve) => setTimeout(resolve, 0));
    assert.equal(h.statuses.size, 0);
});

test("shows placeholders outside Git", async () => {
    const cwd = await temporaryDirectory();
    const h = harness(cwd);
    await h.emit({ type: "session_start", reason: "startup" });
    await waitFor(() => plain(h.statuses.get("dotfiles-git-branch-diff") ?? "") === "Git: no repository");
    assert.equal(h.statuses.get("dotfiles-git-dirty"), theme.fg("dim", "Uncommitted: —"));
});

test("pi-footer renders every required field with native context updates and theme colors", async () => {
    const config = normalizeConfig(JSON.parse(await readFile(new URL("../footer.json", import.meta.url), "utf8")));
    const store = WidgetStore.fromConfig(config);
    assert.deepEqual(
        config.lines.map((line) => line.map((widget) => widget.type)),
        [
            ["model-provider", "thinking-level", "context-length", "separator", "context-window", "cwd", "git-branch"],
            ["external-status", "external-status"],
            ["session-name", "external-status"],
        ],
    );
    const data: StatuslineData = {
        sessionId: undefined,
        textVerbosity: undefined,
        activeToolCount: 0,
        usingSubscription: false,
        provider: "openai-codex",
        model: "gpt-6-astra",
        thinkingLevel: "medium",
        sessionName: "Footer polish",
        cwd: "/work/project",
        git: { ...EMPTY_GIT_INFO, branch: "feature", isRepo: true },
        contextTokens: 14000,
        contextMaxTokens: 1000000,
        eventWidgets: new Map(),
        metrics: collectSessionMetrics([]),
        turnMetrics: collectTurnMetrics([]),
    };
    const h = harness(await temporaryDirectory());
    readSkill(h.session, "reporting/SKILL.md", { content: "---\nname: reporting\n---\nInstructions" });
    await h.emit({ type: "session_start", reason: "startup" });
    await waitFor(() => plain(h.statuses.get("dotfiles-git-branch-diff") ?? "") === "Git: no repository");
    h.statuses.set("dotfiles-git-branch-diff", "Since main: 1 file +5 -2");
    h.statuses.set("dotfiles-git-dirty", "Uncommitted: 2 files +3 -1");
    const options = { theme, getExtensionStatuses: () => h.statuses };
    for (const width of [80, 120, 160]) {
        const lines = renderStatuslines(store, data, width, options);
        const text = plain(lines.join("\n"));
        for (const value of [
            "openai-codex/gpt-6-astra medium",
            "Session: Footer polish",
            "/work/project",
            "(feature)",
            "14k/1.0M",
            "Skills (1): reporting",
            "Since main: 1 file +5 -2",
            "Uncommitted: 2 files +3 -1",
        ]) {
            assert.ok(text.includes(value), `missing ${value} at width ${width}: ${text}`);
        }
        assert.equal(lines.length, 3);
        assert.ok(lines.every((line) => visibleWidth(line) <= width));
        assert.doesNotMatch(text, /[%█▓░]/);
    }
    const tokenCases: [number | undefined, string][] = [
        [0, "0/1.0M"],
        [900000, "900k/1.0M"],
        [undefined, "?/1.0M"],
    ];
    for (const [tokens, expected] of tokenCases) {
        const updated = plain(renderStatuslines(store, { ...data, contextTokens: tokens }, 120, options).join("\n"));
        assert.ok(updated.includes(expected), updated);
    }
    // Automatic separators don't receive the theme in pi-footer 0.5.1.
    // Use whitespace; visible separators (the context slash) are themed widgets.
    assert.equal(config.separator, "space");
    const colorCases: [number, ThemeColor][] = [
        [14000, "dim"],
        [750000, "warning"],
        [900000, "error"],
    ];
    for (const activeTheme of [getThemeByName("dark"), getThemeByName("light")]) {
        for (const [tokens, color] of colorCases) {
            const lines = renderStatuslines(store, { ...data, contextTokens: tokens }, 160, {
                ...options,
                theme: activeTheme,
            });
            assert.ok(lines[0].includes(activeTheme.fg("accent", "openai-codex/gpt-6-astra")));
            assert.ok(lines[0].includes(activeTheme.fg("dim", "medium")));
            assert.ok(lines[0].includes(activeTheme.fg(color, `${tokens / 1000}k`)));
            assert.ok(lines[0].includes(activeTheme.fg("dim", "/")));
            assert.ok(lines[2].includes(activeTheme.fg("accent", "Session: Footer polish")));
            assert.ok(lines[2].includes(activeTheme.fg("dim", "Skills (1): reporting")));
        }
    }
    const switched = plain(renderStatuslines(store, { ...data, contextMaxTokens: 200000 }, 120, options).join("\n"));
    assert.ok(switched.includes("14k/200k"));
    const renamed = renderStatuslines(
        store,
        { ...data, thinkingLevel: "high", sessionName: "Review" },
        120,
        options,
    ).map(plain);
    assert.ok(renamed[0].includes("gpt-6-astra high"));
    assert.ok(renamed[2].includes("Session: Review"));
    for (const sessionName of [undefined, ""]) {
        const unnamed = renderStatuslines(store, { ...data, thinkingLevel: undefined, sessionName }, 120, options).map(
            plain,
        );
        assert.ok(unnamed[0].startsWith("openai-codex/gpt-6-astra 14k/1.0M"));
        assert.equal(unnamed[2], "Skills (1): reporting");
    }
    for (const width of [40, 48]) {
        const narrow = renderStatuslines(store, data, width, options);
        assert.equal(narrow.length, 3);
        assert.ok(narrow.every((line) => visibleWidth(line) <= width));
        assert.ok(plain(narrow[0]).includes("medium"));
        assert.ok(plain(narrow[2]).includes("Session: Footer polish"));
        if (width >= 48) {
            assert.ok(plain(narrow[0]).includes("14k/1.0M"));
            assert.ok(plain(narrow[2]).includes("Skills (1): reporting"));
        }
    }
    const noRepo = plain(renderStatuslines(store, { ...data, git: EMPTY_GIT_INFO }, 120, options).join("\n"));
    assert.ok(noRepo.includes("(no git)"));
    assert.deepEqual(config.extensionStatusRow.hiddenKeys, [
        "dotfiles-git-branch-diff",
        "dotfiles-git-dirty",
        "dotfiles-loaded-skills",
    ]);
});
