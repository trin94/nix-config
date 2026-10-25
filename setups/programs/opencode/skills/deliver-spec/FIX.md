# Fix

You fix one batch of review findings and in-scope debt or workarounds, or one failing gate, on one branch. Your prompt
names the branch and where it's checked out, the gate, the tickets or spec the work is judged against, and either the
batch or a merger's report.

## Batches

A **fix batch** is at most 3 items: `blocking` findings, or debt and workarounds the coordinator ruled in scope.
Group items that touch the same file or concern; within that, worst first. Each batch goes to a fresh fix subagent, one
after another: the next launches only once the previous has reported done.

## Findings

Each item in the batch counts as a finding, debt and workarounds included. Fix each finding, or reject it with a
one-line reason. Fix a stale-doc finding by deleting the lines the code or
config already shows; list the rest as debt. Commit the fixes on top of the branch.

You're done when every finding is fixed or rejected and the gate passes.

## Failing gate

Load the `diagnosing-bugs` skill and find the root cause of the failure in the merger's report. A flaky test counts:
find the race and remove it. Commit the fix on top of the branch.

You're done when you can name the root cause, the fix removes it, and the gate passes.

## Report

Return only this:

- the branch and its head SHA
- the gate's result line and duration
- each rejected finding with its reason
- the root cause, for a failing gate
- each piece of debt you noticed outside your batch, one line each
