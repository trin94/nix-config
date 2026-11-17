// The main conversation's todo list, as OpenCode's sidebar shows it. Claude Code keeps it with one of two
// tool families: TodoWrite rewrites the whole list, TaskCreate and TaskUpdate edit it item by item.

import type { SessionMessage } from "claude-code";

import type { Todo, TodoStatus } from "../types";
import type { Ui } from "./ui";

const STATUSES: readonly string[] = ["pending", "in_progress", "completed"];

const isStatus = (value: unknown): value is TodoStatus => typeof value === "string" && STATUSES.includes(value);

/** A field of a stored tool record, whose shape the transcript does not promise. */
const field = (value: unknown, key: string): unknown =>
    typeof value === "object" && value !== null ? Reflect.get(value, key) : undefined;

function todoWriteList(input: Record<string, unknown>): Todo[] {
    const todos = Array.isArray(input.todos) ? input.todos : [];
    return todos.flatMap((item) => {
        const content = field(item, "content");
        const status = field(item, "status");
        if (typeof content !== "string" || !isStatus(status)) return [];
        return [{ content, status }];
    });
}

/** The list the last-used tool family left, in creation order. */
export function currentTodos(messages: readonly SessionMessage[]): Todo[] {
    let written: Todo[] = [];
    const tasks = new Map<string, Todo>();
    let usesTasks = false;

    for (const message of messages) {
        if (message.role !== "assistant") continue;
        for (const use of message.toolUses) {
            if (use.isError) continue;
            if (use.tool === "TodoWrite") {
                written = todoWriteList(use.input);
                usesTasks = false;
            } else if (use.tool === "TaskCreate") {
                const task = field(use.result, "task");
                const id = field(task, "id");
                const subject = field(task, "subject");
                if (typeof id !== "string" || typeof subject !== "string") continue;
                tasks.set(id, { content: subject, status: "pending" });
                usesTasks = true;
            } else if (use.tool === "TaskUpdate") {
                const id = use.input.taskId;
                const task = typeof id === "string" ? tasks.get(id) : undefined;
                if (typeof id !== "string" || !task) continue;
                if (use.input.status === "deleted") tasks.delete(id);
                else
                    tasks.set(id, {
                        content: typeof use.input.subject === "string" ? use.input.subject : task.content,
                        status: isStatus(use.input.status) ? use.input.status : task.status,
                    });
                usesTasks = true;
            }
        }
    }
    return usesTasks ? [...tasks.values()] : written;
}

/** Shown while anything is left to do, as OpenCode hides a finished list. */
export const hasOpenTodos = (todos: readonly Todo[]) => todos.some((todo) => todo.status !== "completed");

export function todoMark(status: TodoStatus): string {
    if (status === "completed") return "[x]";
    if (status === "in_progress") return "[•]";
    return "[ ]";
}

export function Todos({ Box, Text }: Ui, todos: readonly Todo[]) {
    if (!hasOpenTodos(todos)) return null;
    return (
        <Box flexDirection="column">
            <Text bold>Todo</Text>
            {todos.map((todo) => (
                <Text dimColor={todo.status !== "in_progress"} wrap="truncate-end">
                    {todoMark(todo.status)} {todo.content}
                </Text>
            ))}
        </Box>
    );
}
