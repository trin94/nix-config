// Connected MCP servers. Claude Code hands plugins no server list, so they are read off the tools the
// session offers: a server whose tools are listed is connected.

import type { ToolInfo } from "claude-code";

import type { McpServer } from "../types";
import type { Ui } from "./ui";

const PREFIX = "mcp__";

/** `mcp__claude_ai_Gmail__create_draft` -> `claude_ai_Gmail`. */
function serverOf(toolName: string): string | undefined {
    if (!toolName.startsWith(PREFIX)) return;
    const end = toolName.indexOf("__", PREFIX.length);
    return end === -1 ? undefined : toolName.slice(PREFIX.length, end);
}

/** claude.ai connectors as /mcp names them; other servers keep their own spelling. */
export function serverLabel(server: string): string {
    return server.startsWith("claude_ai_") ? `claude.ai ${server.slice(10).replaceAll("_", " ")}` : server;
}

/** Servers in first-listed order with their tool counts. */
export function mcpServers(tools: readonly ToolInfo[]): McpServer[] {
    const counts = new Map<string, number>();
    for (const tool of tools) {
        const server = tool.mcp ? serverOf(tool.name) : undefined;
        if (server) counts.set(server, (counts.get(server) ?? 0) + 1);
    }
    return [...counts].map(([server, count]) => ({ name: serverLabel(server), tools: count }));
}

export function Mcp({ Box, Text }: Ui, servers: readonly McpServer[]) {
    if (servers.length === 0) return null;
    return (
        <Box flexDirection="column">
            <Text bold>MCP</Text>
            {servers.map((server) => (
                <Box flexDirection="row" gap={1}>
                    <Text color="success">•</Text>
                    <Text dimColor wrap="truncate-end">
                        {server.name}
                    </Text>
                    <Text dimColor>{server.tools}</Text>
                </Box>
            ))}
        </Box>
    );
}
