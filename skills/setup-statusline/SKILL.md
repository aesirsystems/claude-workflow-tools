---
name: setup-statusline
description: Configure the enhanced statusline in Claude Code settings. Run this once after installing the plugin.
disable-model-invocation: true
allowed-tools: Read, Edit, Bash
---

# Setup Enhanced Statusline

Install the workflow-tools statusline into your Claude Code settings.

## Step 1: Find the plugin path

```bash
# Find where the plugin is cached
PLUGIN_PATH=$(find ~/.claude/plugins/cache -name "statusline.sh" -path "*/workflow-tools/*" 2>/dev/null | head -1)
echo "Statusline script: $PLUGIN_PATH"
```

If not found, the script is at `${CLAUDE_PLUGIN_ROOT}/bin/statusline.sh`.

## Step 2: Make executable

```bash
chmod +x "$PLUGIN_PATH"
```

## Step 3: Update settings

Read `~/.claude/settings.json` and add or update the `statusLine` key:

```json
{
  "statusLine": {
    "type": "command",
    "command": "<PLUGIN_PATH>/bin/statusline.sh",
    "padding": 0
  }
}
```

Use the Edit tool to add this to the user's `~/.claude/settings.json`.

## Step 4: Verify

Tell the user the statusline is configured. It will appear on the next prompt.

**Features:**
- Model name with context size (e.g., `Opus 4.6 1000k EXT`)
- Auth method (Sub/API)
- Git branch + dirty file count (in git repos)
- Compact `~/path` display (outside git repos)
- Context usage bar with color coding (green/yellow/red)
- Session duration and code churn stats
- `/compact` warning at 85%+ usage
