---
name: spec-to-issue
description: Create a GitHub issue from a superpowers spec file in docs/superpowers/specs/. Use this skill whenever the user asks to "file an issue for this spec", "open a GitHub issue from this spec", "create an issue from a spec", "turn this spec into a GitHub issue", "spec to issue", or anything similar — even when they don't say the words "skill" or "spec-to-issue". Also use it when the user says "make a github issue" right after writing or reviewing a file under docs/superpowers/specs/. Accepts an optional spec path; if omitted, uses the most recent file in docs/superpowers/specs/. Always invoke this skill rather than running gh issue create by hand, because it handles deduplication via a Spec: footer marker and applies the spec label consistently.
---

# spec-to-issue

Turn a superpowers spec file in `docs/superpowers/specs/` into a GitHub issue on the current repo. One issue per spec, deduplicated by a footer marker, labeled `spec`.

## When invoked

Follow these steps in order. If any step fails, surface the error verbatim and stop.

### 1. Resolve the spec path

If the user provided a path, use it. Otherwise pick the newest file in `docs/superpowers/specs/`:

```bash
SPEC_PATH="${1:-$(ls -t docs/superpowers/specs/*.md 2>/dev/null | head -1)}"
[ -z "$SPEC_PATH" ] && { echo "No specs in docs/superpowers/specs/"; exit 1; }
[ -f "$SPEC_PATH" ] || { echo "No spec found at $SPEC_PATH"; exit 1; }
```

### 2. Extract the title

Read the first `# ` H1 line. If absent, derive from the filename (strip `YYYY-MM-DD-` prefix and `.md` suffix, replace dashes with spaces) and warn the user.

```bash
TITLE="$(grep -m1 '^# ' "$SPEC_PATH" | sed 's/^# //')"
if [ -z "$TITLE" ]; then
  BASE="$(basename "$SPEC_PATH" .md)"
  TITLE="$(echo "$BASE" | sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}-//' | tr '-' ' ')"
  echo "Warning: spec has no H1; using filename-derived title: $TITLE"
fi
```

### 3. Dedup check

Search existing issues (open and closed) for the `Spec:` footer marker.

```bash
EXISTING="$(gh issue list --search "Spec: $SPEC_PATH" --state all --json number,title,url --limit 5)"
COUNT="$(echo "$EXISTING" | jq 'length')"
if [ "$COUNT" -gt 0 ]; then
  echo "Issue already exists for this spec:"
  echo "$EXISTING" | jq -r '.[] | "  #\(.number) \(.title) — \(.url)"'
  exit 0
fi
```

### 4. Ensure the `spec` label exists

```bash
gh label create spec --color BFD4F2 \
  --description "Tracked by a spec in docs/superpowers/specs/" \
  2>/dev/null || true
```

### 5. Build the body

Use the spec's `## Goal` section if present; otherwise use the first non-empty paragraph after the H1.

```bash
GOAL="$(awk '/^## Goal/{flag=1; next} /^## /{flag=0} flag' "$SPEC_PATH" | sed '/./,$!d' | awk 'NF{p=1} p; p && !NF{exit}')"
if [ -z "$GOAL" ]; then
  GOAL="$(awk '/^# /{flag=1; next} flag && NF{print; exit}' "$SPEC_PATH")"
fi

BODY="$(printf '%s\n\n---\nSpec: %s\n' "$GOAL" "$SPEC_PATH")"
```

### 6. Create the issue

```bash
gh issue create --title "$TITLE" --label spec --body "$BODY"
```

### 7. Report

`gh issue create` prints the new issue URL on success. Show that URL to the user as the final output.

## Notes

- Fire-and-report. Do not retry, modify the spec file, or make commits.
- The `Spec:` footer line is the dedup marker — do not remove or rephrase it.
- If `gh` is not authenticated or the working directory is not a GitHub repo, `gh` will surface the error; let it propagate.
