// Test preload: serves Pi's packages from Pi's own install, where Pi finds them when it loads the extension.

import { mock } from "bun:test";
import { readFileSync } from "node:fs";
import { homedir } from "node:os";

const install = `${process.env.PI_CODING_AGENT_DIR ?? `${homedir()}/.pi/agent`}/install`;
const version = readFileSync(`${install}/current-version`, "utf8").trim();
const modules = `${install}/releases/${version}/node_modules`;

for (const name of ["@earendil-works/pi-tui"]) {
    const module = await import(Bun.resolveSync(name, modules));
    mock.module(name, () => module);
}
