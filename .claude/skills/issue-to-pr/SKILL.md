---
name: issue-to-pr
description: Run the full development pipeline for a GitHub issue — spec to implemented PR. Use when the user says "implement issue N", "work on issue <URL>", "run the pipeline for issue N", "go from issue to PR", "issue to PR for #N", "automate issue <title>", or "spec to PR". Accepts a GitHub issue URL, number, or title string.
---

# issue-to-pr

Automate the full development pipeline from a GitHub issue to a PR:

1. Resolve the issue
2. Find its spec file
3. Create a feature branch
4. Write an implementation plan
5. Execute the plan with subagent-driven development
6. Open the PR

---

## Step 1: Resolve the issue number

The input may be a URL, issue number, or title string. Run the appropriate command:

**URL** (contains `github.com/`):
```bash
N=$(echo "<input>" | sed 's|.*/issues/||' | tr -d '[:space:]')
```

**Number** — use directly as `N`.

**Title string**:
```bash
RESULT=$(gh issue list --search "<input>" --limit 1 --json number,title 2>&1)
N=$(echo "$RESULT" | jq -r '.[0].number // empty')
```

If `N` is empty after resolution:
> "Could not find issue: <input>"

Stop — do not proceed.

---

## Step 2: Fetch the issue

```bash
ISSUE=$(gh issue view "$N" --json title,body)
TITLE=$(echo "$ISSUE" | jq -r '.title')
BODY=$(echo "$ISSUE" | jq -r '.body')
```

If `gh issue view` fails, surface the error verbatim and stop.

---

## Step 3: Extract the Spec: path

```bash
SPEC_PATH=$(echo "$BODY" | grep '^Spec: ' | sed 's/^Spec: //' | tr -d '[:space:]')
```

If `SPEC_PATH` is empty, stop with:
> "Issue #N has no Spec: footer — was it created with spec-to-issue?"

If the spec file does not exist on disk, stop with:
> "Spec file not found: <SPEC_PATH>"

---

## Step 4: Create the feature branch

```bash
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g' | cut -c1-50)
BRANCH="feat/issue-${N}-${SLUG}"
git checkout -b "$BRANCH"
```

All implementation happens on this branch.

---

## Step 5: Write the implementation plan

Invoke the `superpowers:writing-plans` skill with this context:

> "The spec for this work is at `<SPEC_PATH>`. Read it and write the implementation plan."

The skill will write the plan to `docs/superpowers/plans/YYYY-MM-DD-<slug>.md`. Do not pause after the plan is written — proceed immediately to execution.

---

## Step 6: Execute the plan

Immediately invoke the `superpowers:subagent-driven-development` skill. No pause. Run all tasks to completion with the standard two-stage review (spec compliance + code quality) per task.

---

## Step 7: Open the PR

After all tasks pass review:

```bash
git push -u origin "$BRANCH"
```

Then create the PR:

```bash
gh pr create \
  --title "$TITLE" \
  --body "$(cat <<EOF
Closes #${N}

## Summary
<2-3 bullets describing what was built, derived from the plan goal and architecture sections>

## Test Plan
<checklist from the plan's verification or E2E task — copy the checkboxes verbatim>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Print the PR URL as the final output.
