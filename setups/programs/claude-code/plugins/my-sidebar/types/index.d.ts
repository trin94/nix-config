/** Folds the person clicked, by agent id: true expanded, false folded. */
export type Folds = Record<string, boolean>;

export type Stats = {
    files: number;
    additions: number;
    deletions: number;
};

export type GitStatus = {
    /** The branch, or the short commit when detached. */
    head: string;
    /** The default branch the branch stats count from. */
    base: string;
    branch: Stats;
    dirty: Stats;
};

/**
 * What the sidebar keeps of a subagent, so it stays listed after Claude Code drops it from `$.agent.list()`.
 * The fields mirror AgentInfo's.
 */
export type AgentSnapshot = {
    id: string;
    parentId?: string;
    description: string;
    type: string;
    status: string;
    startTime: number;
    tokenCount: number;
    contextWindowSize?: number;
    /** No longer in `$.agent.list()`: its transcript can no longer be put in view. */
    isGone?: boolean;
};

export type TodoStatus = "pending" | "in_progress" | "completed";

export type Todo = {
    content: string;
    status: TodoStatus;
};

export type McpServer = {
    /** As /mcp names it. */
    name: string;
    tools: number;
};

declare module "claude-code" {
    interface PluginState {
        "my-sidebar": {
            folds: Shaped<Folds>;
            /** Null outside a repository. */
            git: Shaped<GitStatus | null>;
            skills: Shaped<string[]>;
            /** Every name a skill Claude Code expanded this session goes by, for telling slash commands apart. */
            expanded: Shaped<string[]>;
            /** The session's title, null before Claude Code names it. */
            title: Shaped<string | null>;
            /** The main loop's effort on its last request, null before one or on a model that takes none. */
            effort: Shaped<string | null>;
            /** The main loop's permission mode as the last settings-hook event reported it. */
            mode: Shaped<string | null>;
            todos: Shaped<Todo[]>;
            mcp: Shaped<McpServer[]>;
            /** Every subagent seen this session, by id, as last listed. */
            seen: Shaped<Record<string, AgentSnapshot>>;
        };
    }
}
