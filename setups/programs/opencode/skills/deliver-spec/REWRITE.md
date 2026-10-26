# History rewrite

Rewrite the integration branch's history since main so the current state looks like it was the plan from the start.

Load the `commit-conventions` skill, plus the project's `commit` or `committing` skill when present.

1. Tag the current tip as a backup.
2. Write 1-2 commits per ticket in task-graph order, each naming its ticket the way the tracker links commits.
3. Fold each fix into the commit of the ticket it belongs to. A fix spanning several tickets goes into the latest
   of them.
4. Check that the history is linear and `git diff <backup> HEAD` is empty. The tip's tree is the backup's, which the
   merger already gated: no gate runs here.
5. If the branch has a remote, push with `--force-with-lease`.
6. Delete the backup tag.

You're done when the backup tag is gone and the remote, if any, matches the tip.

## Report

Return only the new tip's SHA and `git log --oneline main..HEAD`.
