# Cog Focus

A single-goal cognitive architecture for Claude Code. Clone this template, define your goal, start working. Claude maintains persistent memory focused on that one goal.

Inspired by [Cog](https://github.com/marciopuga/cog) — simplified from multi-domain to single-goal.

## Quick Start

```bash
git clone <this-repo> my-project
cd my-project
```

1. Edit `goal.md` — define what you're trying to accomplish
2. Open in Claude Code
3. Start working

## How It Works

`CLAUDE.md` teaches Claude Code to maintain persistent memory across sessions. Everything serves the goal you define in `goal.md`.

### Memory

```
memory/
  hot-memory.md       # What matters right now (<50 lines)
  observations.md     # Event log (append-only)
  action-items.md     # Tasks serving the goal
  patterns.md         # Learned rules (<50 lines)
  archive/            # Old data, indexed
```

### Skills

| Skill | What it does |
|-------|-------------|
| `/reflect` | Review sessions, check goal progress, condense patterns |
| `/housekeeping` | Archive old data, prune hot-memory, surface stale items |
| `/commit` | Git commit with conventional format |

### Threads

When a topic comes up 3+ times across observations, raise it into a **thread** — a synthesis file in `memory/` with Current State / Timeline / Insights sections. One file per topic, forever.

## Design Principles

- **One goal** — everything serves it. No multi-domain routing.
- **Plain text** — markdown files, grep-friendly, git-trackable.
- **Flat structure** — 5 core files, no nesting.
- **Progressive condensation** — observations → patterns → hot-memory.

## License

MIT
