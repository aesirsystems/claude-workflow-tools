# Setup Guide

## Prerequisites

### Required

- **Claude Code** — [install guide](https://docs.anthropic.com/en/docs/claude-code)

### Optional

- **beads** — git-backed task tracker. The prepare-compact and restore-context skills use beads for task state. Without it, those sections are skipped gracefully.
  ```bash
  brew install steveyegge/beads/bd
  cd your-project && bd init
  ```

## Installation

### Step 1: Add marketplace and install

```
/plugin marketplace add aesirsystems/claude-marketplace
/plugin install breadcrumbs@aesir-marketplace
```

### Step 2: Add recommended permissions

The skills request permissions at runtime, but for a smoother experience add these to `~/.claude/settings.json` under `permissions.allow`:

```json
{
  "permissions": {
    "allow": [
      "Bash(git log:*)",
      "Bash(git status:*)",
      "Bash(git branch:*)",
      "Bash(bd *)",
      "Bash(cat:*)",
      "Bash(ls:*)",
      "Write(.beads/recovery-context.md)",
      "Write(.beads/recovery-prompt.md)",
      "Edit(*MEMORY.md)"
    ]
  }
}
```

## Hooks

Hooks activate automatically when the plugin is enabled:

- **PreCompact** — saves basic recovery state to `.beads/recovery-context.md` before compaction
- **PostCompact** — loads recovery state into Claude's context after compaction

These only run in projects with a `.beads/` directory. In non-beads projects, they exit silently.

## Skills

| Skill | Invoke with | When to use |
|-------|-------------|-------------|
| prepare-compact | `/breadcrumbs:prepare-compact` | Before `/compact` — saves complete strategic context |
| restore-context | `/breadcrumbs:restore-context` | After `/compact` or new session — reloads everything |

## Using without beads

The skills degrade gracefully without beads:

- **prepare-compact** — skips beads task updates, still saves git state and recovery files
- **restore-context** — skips beads sync, still reads recovery files and git state
- **hooks** — exit silently if no `.beads/` directory

Recovery files are written to `.beads/` if it exists, otherwise to the project root.

## Updating

```
/plugin update breadcrumbs@aesir-marketplace
```

## Uninstalling

```
/plugin uninstall breadcrumbs@aesir-marketplace
```

## Troubleshooting

### Hooks don't fire
- Verify the plugin is enabled: check `enabledPlugins` in `~/.claude/settings.json`
- Hooks only run in directories with `.beads/` — run `bd init` to create it

### Permission prompts on every use
- Add the recommended permissions from Step 2 above to your settings
