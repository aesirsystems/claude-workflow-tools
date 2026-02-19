# claude-workflow-tools

Claude Code plugin for context preservation across compactions and an enhanced statusline.

## What's included

| Component | Type | Description |
|-----------|------|-------------|
| `/workflow-tools:prepare-compact` | Skill | Save git state, update beads cards, create recovery files before `/compact` |
| `/workflow-tools:restore-context` | Skill | Reload everything after compaction or new session |
| `/workflow-tools:setup-statusline` | Skill | One-time statusline configuration |
| `statusline.sh` | Script | Rich statusline: model, auth, branch/path, context bar, duration, churn |
| PreCompact hook | Hook | Auto-saves basic recovery state before compaction |
| PostCompact hook | Hook | Auto-loads recovery state after compaction |

## Install

```
/plugin marketplace add aesirsystems/claude-marketplace
/plugin install workflow-tools@aesir-marketplace
```

## Setup

After installing, run the setup skill to configure the statusline:

```
/workflow-tools:setup-statusline
```

## Statusline

Shows at-a-glance session info:

```
[Opus 4.6 (1M context) 1000k EXT: Sub] main ~3 ▓▓▓░░░░░░░ 28% | 12m30s | +45/-12
```

- **Model + context size** — what you're running on
- **Auth** — Sub (subscription) or API
- **Branch + dirty count** — git state (or `~/path` outside git repos)
- **Context bar** — green < 50%, yellow 50-79%, red 80%+
- **Duration** — session time
- **Churn** — lines added/removed
- **`/compact` warning** — flashes at 85%+

## Dependencies

- [jq](https://jqlang.github.io/jq/) — for parsing statusline JSON (install: `brew install jq`)
- [beads](https://github.com/steveyegge/beads) — optional, for task tracking features (install: `brew install steveyegge/beads/bd`)

## License

MIT
