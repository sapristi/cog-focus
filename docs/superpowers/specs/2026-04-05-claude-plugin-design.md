# Cog Focus — Claude Code Plugin Design

## Overview

Convert the cog_focus framework from a template-copy scaffold into a Claude Code plugin. The plugin provides persistent single-goal memory and structured reflection for any project, activated per-project via settings.

## Plugin Structure

```
cog-focus/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── cog-init/
│   │   └── SKILL.md
│   ├── reflect/
│   │   └── SKILL.md
│   └── housekeeping/
│       └── SKILL.md
├── hooks/
│   ├── hooks.json
│   └── session-start
├── template/
│   ├── goal.md
│   ├── roadmap.md
│   ├── .gitignore
│   └── memory/
│       ├── hot-memory.md
│       ├── observations.md
│       ├── action-items.md
│       ├── patterns.md
│       ├── reflect-cursor.md
│       └── archive/
│           └── index.md
├── package.json
├── README.md
└── LICENSE
```

## Files Removed

- `template/CLAUDE.md` — replaced by session-start hook injection
- `template/.claude/` — commands replaced by plugin skills, settings no longer needed
- `bin/cog-init` — replaced by `/cog-init` skill
- `cog-init.md` — replaced by `/cog-init` skill
- `/commit` command — dropped

## Components

### 1. Plugin Manifest (`.claude-plugin/plugin.json`)

```json
{
  "name": "cog-focus",
  "description": "Single-goal cognitive architecture with persistent memory and structured reflection",
  "version": "1.0.0",
  "author": {
    "name": "Mathias Millet"
  },
  "license": "MIT"
}
```

### 2. Session-Start Hook

**`hooks/hooks.json`:**
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/session-start\"",
            "async": false
          }
        ]
      }
    ]
  }
}
```

**`hooks/session-start`** (bash script):
1. Reads the current project's `.claude/settings.json`
2. Checks for `"cog-focus": { "enabled": true }`
3. If found, outputs condensed instructions as `additionalContext`
4. If not found, outputs nothing (exit 0, no output)

**Condensed instructions injected (~30 lines):**

```markdown
# Cog Focus — Active Project

## On Session Start
Read these files in order:
1. `goal.md` — north star
2. `roadmap.md` — active milestone
3. `memory/hot-memory.md` — current state
4. `memory/patterns.md` — learned heuristics

## Memory File Map
memory/
  hot-memory.md         # <50 lines, rewrite freely
  observations.md       # Append-only: - YYYY-MM-DD [tags]: observation
  action-items.md       # - [ ] task | due: | pri: | added:
  patterns.md           # <50 lines, edit in place
  archive/              # Old data, managed by /housekeeping

## Edit Patterns
| File | Pattern |
|------|---------|
| hot-memory.md | Rewrite freely |
| observations.md | Append only |
| action-items.md | Append new, check off done |
| patterns.md | Edit in place |

## Behavior
- Orient work toward the **active milestone**, not directly toward the goal.
- Write observations immediately — don't wait.
- Challenge when work doesn't serve the active milestone.
- When a milestone completes, move it to Completed in roadmap.md with date + takeaway.
```

### 3. `/cog-init` Skill

**Frontmatter:**
```yaml
name: cog-init
description: Initialize a Cog Focus project in the current directory — scaffolds goal, roadmap, and memory files
user-invocable: true
```

**Behavior:**
1. Check if `goal.md` or `memory/` already exist. If so, warn the user and ask how to proceed.
2. Check if the current directory is a git repo. If not, ask the user if they want to run `git init`.
3. Locate the template directory at `${CLAUDE_PLUGIN_ROOT}/template/`.
4. Copy template files into the project: `goal.md`, `roadmap.md`, `.gitignore`, `memory/` (with all contents).
5. Add `"cog-focus": { "enabled": true }` to `.claude/settings.json`. Create the file if it doesn't exist. Merge into existing settings if it does.
6. Tell the user what was created and what was modified.
7. Run `git add` for the new files and commit: `chore: initialize cog focus project`.
8. Tell the user: "Cog Focus initialized. Edit `goal.md` to define your goal, then `roadmap.md` to set your first milestone."

### 4. `/reflect` Skill

**Frontmatter:**
```yaml
name: reflect
description: Deep self-reflection — mines sessions, condenses patterns, checks goal progress, maintains memory health
user-invocable: true
```

**Guard:** Check `.claude/settings.json` for `"cog-focus": { "enabled": true }`. If not found, tell the user to run `/cog-init` first and stop.

**Process** (carried from current `template/.claude/commands/reflect.md`):
1. Orientation — check recent memory file changes and entry counts
2. Read all memory files + goal.md + roadmap.md
3. Review recent sessions via reflect-cursor.md
4. Cross-reference memory for gaps and stale data
5. Milestone & goal progress assessment
6. Condensation — observations clusters → patterns
7. Hot-memory relevance — promote heating, demote stale
8. Detect thread candidates (3+ observations across 2+ weeks)
9. Act on findings (max 5 file modifications per pass)
10. Debrief — summary of progress, learnings, fixes, things to watch

**Threads documentation** (moved from template CLAUDE.md into this skill):
- Thread files live in `memory/<topic>.md`
- Structure: Current State (rewrite) | Timeline (append-only) | Insights
- Raised when a topic appears 3+ times across 2+ weeks
- One file forever, never condensed

### 5. `/housekeeping` Skill

**Frontmatter:**
```yaml
name: housekeeping
description: Memory maintenance — archives old data, prunes hot-memory, surfaces stale action items, rebuilds archive index
user-invocable: true
```

**Guard:** Check `.claude/settings.json` for `"cog-focus": { "enabled": true }`. If not found, tell the user to run `/cog-init` first and stop.

**Process** (carried from current `template/.claude/commands/housekeeping.md`):
1. Orientation — check entry counts against thresholds
2. Archive observations if >50 entries (keep 30 recent, move rest to `archive/observations-YYYY.md`)
3. Archive completed action items if >10 (move to `archive/action-items-done.md`)
4. Prune hot-memory under 50 lines (resolved → past events → stale → low-signal)
5. Surface stale action items (open >2 weeks)
6. Rebuild `archive/index.md`
7. Debrief — what was archived/pruned, stale items, issues found

### 6. Template Files

Kept as-is from current `template/` directory, minus the files being removed. These are the raw files that `/cog-init` copies into projects:
- `goal.md` — project goal template
- `roadmap.md` — milestone roadmap template
- `.gitignore` — standard ignores
- `memory/hot-memory.md` — empty hot memory
- `memory/observations.md` — empty observations log
- `memory/action-items.md` — empty action items
- `memory/patterns.md` — empty patterns
- `memory/reflect-cursor.md` — cursor metadata template
- `memory/archive/index.md` — empty archive index

### 7. Package Metadata (`package.json`)

```json
{
  "name": "cog-focus",
  "version": "1.0.0",
  "description": "Single-goal cognitive architecture with persistent memory and structured reflection",
  "author": "Mathias Millet",
  "license": "MIT"
}
```

## Opt-In Mechanism

Per-project activation via `.claude/settings.json`:

```json
{
  "cog-focus": {
    "enabled": true
  }
}
```

- `/cog-init` adds this automatically and tells the user what it did
- Session-start hook checks this before injecting instructions
- `/reflect` and `/housekeeping` check this before running (guard clause)

## What Runs Automatically

Only the session-start hook. It:
1. Reads `.claude/settings.json`
2. If `cog-focus.enabled` is true, injects ~30 lines of condensed instructions
3. Claude then follows those instructions (reads goal.md, etc.) as part of its first response

Nothing else runs automatically. `/reflect` and `/housekeeping` are manual.

## Migration Path

For existing cog_focus users:
1. Install the plugin
2. Remove `template/CLAUDE.md` content from their project's CLAUDE.md (or keep it — no conflict, just redundancy)
3. Remove `.claude/commands/` (reflect, housekeeping, commit) — replaced by plugin skills
4. Add `"cog-focus": { "enabled": true }` to `.claude/settings.json`
