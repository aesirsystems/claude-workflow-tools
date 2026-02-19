---
name: prepare-compact
description: Prepare for context compaction by saving git state, updating beads cards, creating strategic recovery files, and updating persistent memory. Use when context is running low or before /compact.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Prepare for Context Compact

Context is low. Execute ALL steps below IN ORDER. Do not skip any step.

---

## Step 1: Capture Git State

Run these as **three separate parallel Bash calls** (NOT chained with &&):
- `git log --oneline -3`
- `git status --short`
- `git branch --show-current`

If not in a git repo, skip this step and note "Not a git repository" in recovery file.

---

## Step 2: Update Beads Cards

**CRITICAL:** Update beads state BEFORE compaction destroys context.

### A. Close Completed Tasks

Review what was accomplished this session:

```bash
bd list --status open
```

**For each completed task (IDEMPOTENT):**
```bash
if bd show <task-id> 2>/dev/null | grep -q "status: closed"; then
  echo "Task already closed, skipping"
else
  bd update <task-id> --notes "[$(date +%Y-%m-%d)] Completed: [what was done]. Files: [modified files]"
  bd close <task-id>
fi
```

### B. Update In-Progress Tasks

**IDEMPOTENT: Uses --append-notes with timestamp to avoid duplicates**
```bash
bd update <task-id> --append-notes "[$(date +%Y-%m-%d %H:%M)] Current state: [exactly where you are]. Next: [immediate next step]. Files: [list files]"
```

### C. Create Tasks for New Work Discovered

**IDEMPOTENT: Check if task already exists before creating**
```bash
if bd list | grep -q "Task title substring"; then
  echo "Task already exists, skipping"
else
  bd create "Task title" -p [0-3] --description "Detailed description with acceptance criteria"
fi
```

### D. Verify Beads State

```bash
bd ready
bd list
```

If beads is not available, skip this step entirely.

---

## Step 3: Create Strategic Recovery File

**IDEMPOTENT:** Overwrites previous recovery file.

Create `.beads/recovery-context.md` (or `recovery-context.md` if no .beads dir) with COMPLETE strategic context:

```markdown
# RECOVERY CONTEXT - [YYYY-MM-DD]

## Current Epic/Phase
**Goal:** [What you're building/fixing]
**Success Criteria:**
- [How you know this phase is done]

## Progress Status
**Completed this session:**
- [Major accomplishment 1]
- [Major accomplishment 2]

**In progress:**
- [Active work item]
  - Status: [exactly where you are]
  - Files: [specific files]
  - Next: [concrete next action]

## Key Decisions This Session
- **[Decision]:** [What was decided and why]

## Scope Guard Rails
**IN SCOPE:** [Must-have items]
**OUT OF SCOPE:** [Explicitly deferred items]

## Git State
- **Branch:** [branch name]
- **Last commit:** [sha] [message]
- **Uncommitted:** [X files or clean]

## Recovery Commands
cat .beads/recovery-context.md
bd ready
git status
```

---

## Step 4: Update Auto-Memory (MEMORY.md)

Write key LEARNINGS (not session state) to persistent memory. Keep under 200 lines.

**Include:** Architectural patterns, solutions to recurring problems, file relationships.
**Exclude:** Session state (that's in recovery file), specific tasks (that's in beads).

Check before adding to avoid duplicates.

---

## Step 5: Save Recovery Prompt

Write `.beads/recovery-prompt.md`:

```markdown
# RECOVERY PROMPT - [DATE]
# Use /workflow-tools:restore-context after /compact or new session

## Commands
cat .beads/recovery-context.md
bd ready

## Quick Summary
- [1-line accomplishment 1]
- [1-line accomplishment 2]

## Next
[Immediate next task in 1 sentence]

## Focus
[Primary goal] | Avoid: [Main scope creep risk]
```

---

## Step 6: Print Recovery Prompt

Print to terminal so user can see it:

```
===================================================
RECOVERY PROMPT — paste after /compact or use /workflow-tools:restore-context
===================================================

cat .beads/recovery-context.md
bd ready

Quick summary:
- [accomplishments]

Next: [immediate next task]
Focus: [primary goal] | Avoid: [scope creep risk]

===================================================
```

---

## Final Checklist

Before `/compact`, verify:
- [ ] Beads tasks updated (if available)
- [ ] MEMORY.md updated with learnings
- [ ] Recovery file has complete context
- [ ] Recovery prompt saved and printed

**Now you can safely `/compact`.**
**Use `/workflow-tools:restore-context` to reload everything.**
