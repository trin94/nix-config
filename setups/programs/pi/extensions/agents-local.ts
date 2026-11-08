import { readFile } from "node:fs/promises";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/** Adds an untracked AGENTS.local.md from the workspace root to every agent run's project context. */
export default function (pi: ExtensionAPI) {
    pi.on("before_agent_start", async (event, ctx) => {
        const path = join(ctx.cwd, "AGENTS.local.md");
        const content = await readFile(path, "utf8").catch(() => undefined);
        if (content) event.systemPromptOptions.contextFiles.push({ path, content });
    });
}
