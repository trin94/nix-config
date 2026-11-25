import { expect, test } from "bun:test";
import { foldText, state, tree } from "./tree";

const session = (id: string, parentID: string | undefined, created: number) => ({ id, parentID, time: { created } });

// main ─┬─ a ── a1
//       └─ b
const sessions = [
    session("main", undefined, 0),
    session("a", "main", 1),
    session("a1", "a", 2),
    session("b", "main", 3),
];
const closed = () => false;

test("folds an idle subtree into its top row and counts every descendant", () => {
    const { rows, total } = tree(sessions, "main", closed, {});
    expect(rows.map((row) => [row.prefix, row.session.id, foldText(row)])).toEqual([
        ["├─ ", "a", "+1"],
        ["└─ ", "b", undefined],
    ]);
    expect(total).toBe(3);
});

test("opens a subtree with an open session in it and offers to fold it", () => {
    const { rows } = tree(sessions, "main", (id) => id === "a1", {});
    expect(rows.map((row) => [row.prefix, row.session.id, foldText(row)])).toEqual([
        ["├─ ", "a", "−"],
        ["│  └─ ", "a1", undefined],
        ["└─ ", "b", undefined],
    ]);
});

test("a clicked fold wins over the open session", () => {
    const { rows } = tree(sessions, "main", (id) => id === "a1", { a: false });
    expect(rows.map((row) => row.session.id)).toEqual(["a", "b"]);
});

test("marks a session by whether it runs and how its last run ended", () => {
    expect(state({ outcome: "failed" }, true)).toBe("running");
    expect(state({ outcome: "succeeded" }, false)).toBe("done");
    expect(state({}, false)).toBe("done");
    expect(state({ outcome: "failed" }, false)).toBe("failed");
    expect(state({ outcome: "interrupted" }, false)).toBe("failed");
});
