# Setup Guide

## Prerequisites

### Required

- **Claude Code** — [install guide](https://docs.anthropic.com/en/docs/claude-code)
- **jq** — JSON parser used by the statusline
  ```bash
  brew install jq        # macOS
  sudo apt install jq    # Debian/Ubuntu
  ```

### Optional

- **beads** — git-backed task tracker. The prepare-compact and restore-context skills use beads for task state. Without it, those sections are skipped gracefully.
  ```bash
  brew install steveyegge/beads/bd
  cd your-project && bd init
  ```

## Installation

### Step 1: Install the plugin

```
/plugin install aesirsystems/claude-workflow-tools
```

### Step 2: Configure the statusline

Run the setup skill:

```
/workflow-tools:setup-statusline
```

Or manually add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/plugins/cache/workflow-tools@aesirsystems/claude-workflow-tools/bin/statusline.sh",
    "padding": 0
  }
}
```

### Step 3: Add recommended permissions

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

## Configuration

### Statusline

The statusline displays automatically after setup. No configuration needed beyond the `statusLine` entry in settings.

**What each segment shows:**

| Segment | Example | Description |
|---------|---------|-------------|
| Model | `Opus 4.6 (1M context) 1000k` | Model name and context window size |
| EXT | `EXT` | Extended context (>200k) indicator |
| Auth | `Sub` or `API` | Authentication method |
| Location | `main ~3` or `~/github/project` | Git branch + dirty files, or path when outside git |
| Context bar | `▓▓▓░░░░░░░ 28%` | Green <50%, yellow 50-79%, red 80%+ |
| Duration | `12m30s` | Session time (appears after 1 minute) |
| Churn | `+45/-12` | Lines added/removed (appears after first edit) |
| Warning | `/compact` | Red banner at 85%+ context usage |

### Hooks

Hooks activate automatically when the plugin is enabled:

- **PreCompact** — saves basic recovery state to `.beads/recovery-context.md` before compaction
- **PostCompact** — loads recovery state into Claude's context after compaction

These only run in projects with a `.beads/` directory. In non-beads projects, they exit silently.

### Skills

| Skill | Invoke with | When to use |
|-------|-------------|-------------|
| prepare-compact | `/workflow-tools:prepare-compact` | Before `/compact` — saves complete strategic context |
| restore-context | `/workflow-tools:restore-context` | After `/compact` or new session — reloads everything |
| setup-statusline | `/workflow-tools:setup-statusline` | One-time setup after installation |

## Using without beads

The skills degrade gracefully without beads:

- **prepare-compact** — skips beads task updates, still saves git state and recovery files
- **restore-context** — skips beads sync, still reads recovery files and git state
- **hooks** — exit silently if no `.beads/` directory

Recovery files are written to `.beads/` if it exists, otherwise to the project root.

## Updating

```
/plugin update workflow-tools@aesirsystems/claude-workflow-tools
```

## Uninstalling

```
/plugin uninstall workflow-tools@aesirsystems/claude-workflow-tools
```

Remove the `statusLine` entry from `~/.claude/settings.json` if you added it manually.

## Troubleshooting

### Statusline shows nothing
- Check jq is installed: `which jq`
- Check the script is executable: `ls -la ~/.claude/plugins/cache/workflow-tools@aesirsystems/claude-workflow-tools/bin/statusline.sh`
- Run manually to test: `echo '{}' | ~/.claude/plugins/cache/workflow-tools@aesirsystems/claude-workflow-tools/bin/statusline.sh`

### Statusline shows full path instead of ~/...
- Verify `$HOME` is set in your shell: `echo $HOME`
- The script uses `sed` substitution — if `$HOME` or `$USER` aren't set in the execution environment, the path won't be shortened

### Hooks don't fire
- Verify the plugin is enabled: check `enabledPlugins` in `~/.claude/settings.json`
- Hooks only run in directories with `.beads/` — run `bd init` to create it

### Permission prompts on every use
- Add the recommended permissions from Step 4 above to your settings
