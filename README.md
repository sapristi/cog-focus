# Cog Focus

A single-goal cognitive architecture for Claude Code. Install the plugin, initialize a project, define your goal, start working. Claude maintains persistent memory focused on that one goal.

Inspired by [Cog](https://github.com/marciopuga/cog) — simplified from multi-domain to single-goal.

## Installation

### From GitHub

Add this repo as a marketplace, then install the plugin:

```bash
claude plugin marketplace add sapristi/cog-focus
claude plugin install cog-focus@cog-focus-marketplace
```

### From a local clone

```bash
git clone https://github.com/sapristi/cog-focus.git
claude plugin marketplace add /path/to/cog-focus
claude plugin install cog-focus@cog-focus-marketplace
```

### Verify

```bash
claude plugin list
```

You should see `cog-focus` in the output. Restart Claude Code to activate the plugin.

## Quick Start

In any project directory, run `/cog-init`. It will scaffold the memory files, then walk you through defining your goal and first milestones interactively. Once done, start working.

## How It Works

Installing the plugin adds three skills and a session-start hook.

`/cog-init` scaffolds a `cog-focus/` directory in your project containing `config.yaml`, `goal.md`, `roadmap.md`, and the `memory/` subdirectory, then walks you through defining your goal and first milestones.

The session-start hook detects `cog-focus/config.yaml` and injects the memory system instructions for the session. Claude then reads the goal, roadmap, and memory files at the start of each session, maintaining continuity across conversations.

### Project Structure

```
cog-focus/
  config.yaml         # Detection marker + timestamps
  goal.md             # North star
  roadmap.md          # Milestones
  memory/
    hot-memory.md     # What matters right now (<50 lines)
    observations.md   # Event log (append-only)
    action-items.md   # Tasks serving the goal
    patterns.md       # Learned rules (<50 lines)
    archive/          # Old data, indexed
```

### Skills

| Skill | What it does |
|-------|-------------|
| `/cog-init` | Scaffold files, then interactively define your goal and first milestones |
| `/reflect` | Review sessions, check goal progress, condense patterns |
| `/housekeeping` | Archive old data, prune hot-memory, surface stale items |

### Threads

When a topic comes up 3+ times across observations, raise it into a **thread** — a synthesis file in `cog-focus/memory/` with Current State / Timeline / Insights sections. One file per topic, forever.

### Roadmap

`cog-focus/roadmap.md` decomposes the goal into milestones — stepping stones you work through iteratively. Active milestone drives daily work; completed milestones record what you learned. The path is non-linear: milestones get revised, reordered, and added as you learn.

## Design Principles

- **One goal, many milestones** — the goal is stable; the path to it evolves.
- **Plain text** — markdown files, grep-friendly, git-trackable.
- **Self-contained** — everything lives in `cog-focus/`, one directory to track or ignore.
- **Progressive condensation** — observations → patterns → hot-memory.

## Opt-In Per Project

Cog Focus activates per-project by detecting `cog-focus/config.yaml` in the project root, created by `/cog-init`.

## License

MIT
