# Cog Focus

A single-goal cognitive architecture for Claude Code. Initialize a project, define your goal, start working. Claude maintains persistent memory focused on that one goal.

Inspired by [Cog](https://github.com/marciopuga/cog) — simplified from multi-domain to single-goal.

## Quick Start

### Option A: Claude Code command (recommended)

Copy `cog-init.md` to your global Claude commands directory:

```bash
cp cog-init.md ~/.claude/commands/cog-init.md
```

Then in any project directory, run the `/cog-init` slash command inside Claude Code. It will scaffold all the files and create an initial commit.

### Option B: Shell script

```bash
# Clone the framework
git clone <this-repo>

# Initialize a new project
./cog_focus/bin/cog-init ~/dev/my-project
```

### Then

1. Edit `goal.md` — define what you're trying to accomplish
2. Edit `roadmap.md` — break the goal into milestones
3. Open in Claude Code
4. Start working

## How It Works

`CLAUDE.md` teaches Claude Code to maintain persistent memory across sessions. `goal.md` is the north star; `roadmap.md` breaks it into milestones you work through one at a time.

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

### Roadmap

`roadmap.md` decomposes the goal into milestones — stepping stones you work through iteratively. Active milestone drives daily work; completed milestones record what you learned. The path is non-linear: milestones get revised, reordered, and added as you learn.

## Design Principles

- **One goal, many milestones** — the goal is stable; the path to it evolves.
- **Plain text** — markdown files, grep-friendly, git-trackable.
- **Flat structure** — core files at root and in `memory/`, no nesting.
- **Progressive condensation** — observations → patterns → hot-memory.

## License

MIT
