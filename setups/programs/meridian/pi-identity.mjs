// pi-scrub only knows Pi 1.4's opening line. Pi 1.5 reworded it, so this replaces the new wording until
// pi-scrub catches up.
const PI_IDENTITY = /You are a coding assistant running inside pi, a coding agent harness\.[^\n]*/;
const GENERIC_IDENTITY =
    "You are an expert coding assistant. You help users by reading files, executing commands, editing code, and writing new files.";

export default {
    name: "pi-identity-scrub",
    version: "0.1.0",
    onRequest(ctx) {
        if (!ctx.systemContext) return ctx;
        const scrubbed = ctx.systemContext.replace(PI_IDENTITY, GENERIC_IDENTITY);
        return scrubbed === ctx.systemContext ? ctx : { ...ctx, systemContext: scrubbed };
    },
};
