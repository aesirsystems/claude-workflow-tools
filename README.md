# claude-breadcrumbs

Claude Code plugin for context preservation across compactions. Drop breadcrumbs before `/compact`, pick them up after.

## What's included

| Component | Type | Description |
|-----------|------|-------------|
| `/breadcrumbs:prepare-compact` | Skill | Save git state, update beads cards, create recovery files before `/compact` |
| `/breadcrumbs:restore-context` | Skill | Reload everything after compaction or new session |
| PreCompact hook | Hook | Auto-saves basic recovery state before compaction |
| PostCompact hook | Hook | Auto-loads recovery state after compaction |

## Install

```
/plugin marketplace add aesirsystems/claude-marketplace
/plugin install breadcrumbs@aesir-marketplace
```

## Usage

Before compacting:
```
/breadcrumbs:prepare-compact
```

After compacting or starting a new session:
```
/breadcrumbs:restore-context
```

The hooks also run automatically — PreCompact saves a basic recovery file, PostCompact loads it into context.

## Dependencies

- [beads](https://github.com/steveyegge/beads) — optional, for task tracking features (install: `brew install steveyegge/beads/bd`)

Without beads, the skills still save/restore git state and recovery files.

## See also

- [claude-statusline](https://github.com/aesirsystems/claude-statusline) — enhanced statusline for Claude Code

## License

MIT
