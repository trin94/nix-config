import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { Plugin } from "@opencode/plugin";

/** Adds an untracked AGENTS.local.md from the workspace root to every agent request. */
export default Plugin.define({
    id: "my-agents-local",
    async setup(ctx) {
        const path = join(ctx.location.directory, "AGENTS.local.md");
        await ctx.session.hook("context", async (event) => {
            const text = await readFile(path, "utf8").catch(() => undefined);
            if (text) event.system.push({ type: "text", text: `Instructions from: ${path}\n${text}` });
        });
    },
});
