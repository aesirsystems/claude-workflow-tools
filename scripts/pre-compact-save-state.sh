#!/bin/bash
# PreCompact: Save comprehensive recovery state
# Output goes into context automatically

if [ ! -d ".beads" ]; then
  exit 0
fi

# Clean up any beads worktrees that block git operations
if [ -d ".git/beads-worktrees/main" ]; then
  git worktree remove .git/beads-worktrees/main 2>/dev/null || true
  git worktree prune 2>/dev/null || true
fi

# Ensure recovery-context.md is gitignored
if [ -f ".gitignore" ]; then
  if ! grep -qF ".beads/recovery-context.md" .gitignore; then
    echo ".beads/recovery-context.md" >> .gitignore
  fi
fi

echo "Saving recovery context..."
echo ""
echo "REMINDER: Update beads cards before compacting!"
echo "   - Close completed tasks: bd close <id>"
echo "   - Update in-progress: bd update <id> --notes \"Current state...\""
echo "   - Run /workflow-tools:prepare-compact for full workflow"
echo ""

# Create basic recovery file (Claude should enhance via /prepare-compact)
cat > .beads/recovery-context.md <<EOF
# RECOVERY CONTEXT - $(date +%Y-%m-%d)

**Run /workflow-tools:prepare-compact for complete strategic recovery file**

## Quick State
Branch: $(git branch --show-current 2>/dev/null || echo "unknown")
Last commit: $(git log --oneline -1 2>/dev/null || echo "none")
Uncommitted files: $(git status --short 2>/dev/null | wc -l | tr -d ' ')

## Ready Work
EOF

bd ready 2>/dev/null | head -5 >> .beads/recovery-context.md || echo "None" >> .beads/recovery-context.md

echo ""
echo "Basic recovery context saved to .beads/recovery-context.md"
echo "   (Run /workflow-tools:prepare-compact for complete strategic context)"
