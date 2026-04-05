# Cog Focus Plugin Conversion — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the cog_focus framework into a Claude Code plugin with session-start hook, three skills (/cog-init, /reflect, /housekeeping), and per-project opt-in.

**Architecture:** Plugin manifest at `.claude-plugin/plugin.json`. Session-start hook checks project settings and injects condensed instructions. Skills are self-guarded markdown files. Template files stay in `template/` for `/cog-init` to copy.

**Tech Stack:** Bash (hook script), Markdown with YAML frontmatter (skills), JSON (manifests)

---

### Task 1: Create plugin manifest and package.json

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `package.json`

- [ ] **Step 1: Create `.claude-plugin/plugin.json`**

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

- [ ] **Step 2: Create `package.json`**

```json
{
  "name": "cog-focus",
  "version": "1.0.0",
  "description": "Single-goal cognitive architecture with persistent memory and structured reflection",
  "author": "Mathias Millet",
  "license": "MIT"
}
```

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/plugin.json package.json
git commit -m "feat: add plugin manifest and package.json"
```

---

### Task 2: Create session-start hook

**Files:**
- Create: `hooks/hooks.json`
- Create: `hooks/session-start`

- [ ] **Step 1: Create `hooks/hooks.json`**

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

- [ ] **Step 2: Create `hooks/session-start`**

Bash script that:
1. Finds the project's `.claude/settings.json` (walk up from `$PWD` or use current directory)
2. Checks for `"cog-focus"` key with `"enabled": true` using lightweight JSON parsing (grep/jq)
3. If not found, exits silently (`exit 0`, no output)
4. If found, outputs the condensed instructions as `additionalContext` in the correct platform format

The condensed instructions to embed (stored as a variable in the script):

```
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

Use the same platform detection pattern as the superpowers plugin (`CURSOR_PLUGIN_ROOT`, `CLAUDE_PLUGIN_ROOT`, `COPILOT_CLI`) to output the right JSON format. Use `printf` (not heredoc) for the JSON output to avoid bash 5.3+ heredoc hang issue.

Use the same `escape_for_json` function as the superpowers hook for JSON string escaping.

- [ ] **Step 3: Make the hook executable**

```bash
chmod +x hooks/session-start
```

- [ ] **Step 4: Commit**

```bash
git add hooks/hooks.json hooks/session-start
git commit -m "feat: add session-start hook with opt-in check"
```

---

### Task 3: Create `/cog-init` skill

**Files:**
- Create: `skills/cog-init/SKILL.md`

- [ ] **Step 1: Write the skill**

Frontmatter:
```yaml
---
name: cog-init
description: Initialize a Cog Focus project in the current directory — scaffolds goal, roadmap, and memory files
user-invocable: true
---
```

Body content — the skill instructions for Claude:

1. **Guard**: Check if `goal.md` or `memory/` already exist. If so, warn the user and ask how to proceed (overwrite, skip, abort).
2. **Git check**: Check if the current directory is a git repo (`git rev-parse --is-inside-work-tree`). If not, ask the user if they want to run `git init`.
3. **Copy template**: Locate template at `${CLAUDE_PLUGIN_ROOT}/template/`. Copy these files into the project root:
   - `goal.md`
   - `roadmap.md`
   - `.gitignore`
   - `memory/` (entire directory with all contents)
4. **Enable cog-focus**: Read `.claude/settings.json` if it exists. Add `"cog-focus": { "enabled": true }` to the JSON object. If the file doesn't exist, create it with just that key. If it exists, merge the key into the existing object (preserve all other settings).
5. **Git commit**: Stage all new files and commit with message `chore: initialize cog focus project`.
6. **Report**: Tell the user what was created and what was modified. End with: "Cog Focus initialized. Edit `goal.md` to define your goal, then `roadmap.md` to set your first milestone."

- [ ] **Step 2: Commit**

```bash
git add skills/cog-init/SKILL.md
git commit -m "feat: add /cog-init skill"
```

---

### Task 4: Create `/reflect` skill

**Files:**
- Create: `skills/reflect/SKILL.md`

- [ ] **Step 1: Write the skill**

Frontmatter:
```yaml
---
name: reflect
description: Deep self-reflection — mines sessions, condenses patterns, checks goal progress, maintains memory health
user-invocable: true
---
```

Body content — carry over the full content from `template/.claude/commands/reflect.md` with these additions:

1. **Guard clause at the top**: Check `.claude/settings.json` for `"cog-focus": { "enabled": true }`. If not found, output: "This skill is meant for repositories where cog-focus is enabled. Run `/cog-init` to set up cog-focus in this project." Then stop.

2. **Threads section** (moved from template CLAUDE.md — add after the main process section):

```markdown
## Threads

When a topic keeps coming up across observations, raise it into a **thread** — a synthesis file that pulls scattered fragments into a coherent narrative.

Thread files live in `memory/` (e.g., `memory/deployment-strategy.md`). Structure:
- **Current State** — what's true right now (rewrite freely)
- **Timeline** — dated entries, append-only, full detail preserved
- **Insights** — patterns, learnings, what's different this time

A thread gets raised when a topic appears in 3+ observations across 2+ weeks, or when the user says "raise X" or "thread X". Threads reference observations by date. One file forever, never condensed.
```

Keep everything else from the existing reflect.md as-is.

- [ ] **Step 2: Commit**

```bash
git add skills/reflect/SKILL.md
git commit -m "feat: add /reflect skill"
```

---

### Task 5: Create `/housekeeping` skill

**Files:**
- Create: `skills/housekeeping/SKILL.md`

- [ ] **Step 1: Write the skill**

Frontmatter:
```yaml
---
name: housekeeping
description: Memory maintenance — archives old data, prunes hot-memory, surfaces stale action items, rebuilds archive index
user-invocable: true
---
```

Body content — carry over the full content from `template/.claude/commands/housekeeping.md` with this addition:

1. **Guard clause at the top**: Check `.claude/settings.json` for `"cog-focus": { "enabled": true }`. If not found, output: "This skill is meant for repositories where cog-focus is enabled. Run `/cog-init` to set up cog-focus in this project." Then stop.

Keep everything else from the existing housekeeping.md as-is.

- [ ] **Step 2: Commit**

```bash
git add skills/housekeeping/SKILL.md
git commit -m "feat: add /housekeeping skill"
```

---

### Task 6: Clean up removed files

**Files:**
- Delete: `template/CLAUDE.md`
- Delete: `template/.claude/settings.json`
- Delete: `template/.claude/commands/commit.md`
- Delete: `template/.claude/commands/reflect.md`
- Delete: `template/.claude/commands/housekeeping.md`
- Delete: `bin/cog-init`
- Delete: `cog-init.md`

- [ ] **Step 1: Remove the files**

```bash
rm template/CLAUDE.md
rm template/.claude/settings.json
rm template/.claude/commands/commit.md
rm template/.claude/commands/reflect.md
rm template/.claude/commands/housekeeping.md
rmdir template/.claude/commands
rmdir template/.claude
rm bin/cog-init
rmdir bin
rm cog-init.md
```

- [ ] **Step 2: Commit**

```bash
git add -A
git commit -m "refactor: remove files replaced by plugin skills and hooks"
```

---

### Task 7: Update README.md and CLAUDE.md

**Files:**
- Modify: `README.md`
- Modify: `CLAUDE.md`

- [ ] **Step 1: Rewrite README.md**

Update to reflect the plugin nature of the project. Cover:
- What it is (Claude Code plugin for single-goal cognitive architecture)
- Installation (how to install as a Claude Code plugin)
- Usage: `/cog-init` to scaffold, then `/reflect` and `/housekeeping` for maintenance
- Per-project opt-in via `.claude/settings.json`
- What the session-start hook does
- File structure created by `/cog-init`
- Brief description of each skill

Remove references to `bin/cog-init`, `cog-init.md`, and the old template-copy workflow.

- [ ] **Step 2: Update CLAUDE.md**

Update the framework development instructions to reflect the new plugin structure:
- Skills live in `skills/`
- Hook lives in `hooks/`
- Template files still live in `template/`
- No more `bin/` or root-level `cog-init.md`

- [ ] **Step 3: Commit**

```bash
git add README.md CLAUDE.md
git commit -m "docs: update README and CLAUDE.md for plugin structure"
```

---

### Task 8: Update .claude/settings.local.json

**Files:**
- Modify: `.claude/settings.local.json`

- [ ] **Step 1: Read and update settings**

Check current contents. Update permissions if needed — the old settings may reference `bin/cog-init` or template copy commands that no longer exist. Ensure permissions cover what's needed for plugin development (read, edit, write, glob, grep, git commands).

- [ ] **Step 2: Commit (if changed)**

```bash
git add .claude/settings.local.json
git commit -m "chore: update local settings for plugin structure"
```
