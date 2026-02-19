---
name: restore-context
description: Restore full context after compaction or starting a new session. Reads recovery files, syncs beads state, verifies git state, and presents summary with available work.
allowed-tools: Read, Bash, Glob, Grep
---

# Restore Context

You are returning after compaction or time away. Follow this process to restore COMPLETE context.

---

## Step 0: Read Recovery Prompt (Quick Start)

```bash
if [ -f .beads/recovery-prompt.md ]; then
  cat .beads/recovery-prompt.md
  echo ""
  echo "--- Recovery prompt found. Reading full context next... ---"
else
  echo "No recovery prompt found. Will read recovery context directly."
fi
```

---

## Step 1: Read Recovery File

```bash
cat .beads/recovery-context.md 2>/dev/null || cat recovery-context.md 2>/dev/null || echo "No recovery file found"
```

**Absorb:**
- Current epic and success criteria
- Scope guard rails
- Key decisions and why
- Current challenges
- Exact state of in-progress work

---

## Step 2: Sync and Review Beads

```bash
bd sync --from-main 2>/dev/null || true
bd ready
bd list --status open
```

If beads is not available, skip this step.

---

## Step 3: Verify Git State

```bash
git status
git log --oneline -5
git branch --show-current
```

If not in a git repo, skip this step.

---

## Step 4: Present Summary and Get Direction

Show the user:

```markdown
## Context Restored

### Current Epic
**[Epic name]**
- Goal: [brief description]
- Success: [1-2 key criteria]

### Last Session Completed
- [Major accomplishment 1]
- [Major accomplishment 2]

### Available Work (bd ready)
1. **[task-id]** - [Title] (P[priority])
2. **[task-id]** - [Title] (P[priority])

### Git State
- Branch: [branch]
- Uncommitted: [X files or clean]

### Scope Reminder
Focus on: [primary goal]
Avoid: [main scope creep risk]

---

**Which task would you like to work on?**
```

**WAIT for user response before starting work.**

---

## If No Recovery File

**Fallback process:**
1. Read CLAUDE.md for project overview
2. Read MEMORY.md for architecture patterns
3. Run `bd list` to see all work
4. Check git log for recent activity
5. **Ask user** what to work on
