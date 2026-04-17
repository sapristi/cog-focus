# Cog Focus — Active Project

## On Session Start
Read these files in order:
1. `cog-focus/roadmap.md` — Goal (locked), active milestone, subtasks, untriaged
2. `cog-focus/memory/hot-memory.md` — current state
3. `cog-focus/memory/patterns.md` — learned heuristics

## File Map
cog-focus/
  roadmap.md            # Goal (locked) + Milestones + Subtasks + Untriaged inbox
  memory/
    hot-memory.md       # <50 lines, rewrite freely
    observations.md     # Append-only + ref counter edits. Format: - YYYY-MM-DD [tags]: observation [ | refs: N ]
    patterns.md         # <50 lines, edit in place
    archive/            # Old data, managed by /housekeeping

## Tasks
One surface: `roadmap.md`.
- If the task serves a known milestone, add it to that milestone's **Subtasks**.
- If it's not yet scoped (or is cross-cutting), add it under **Untriaged**.
- `/housekeeping` will help move Untriaged items into the right milestone.

Subtask format: `- [ ] task | pri:high/med/low | added:YYYY-MM-DD`

## Edit Patterns
| File | Pattern |
|------|---------|
| hot-memory.md | Rewrite freely |
| observations.md | Append only, except `\| refs: N` suffix edits (see Ref Counting below) |
| roadmap.md | Edit milestones, Subtasks, and Untriaged in place. **Goal section is locked** — don't edit without explicit user request. |
| patterns.md | Edit in place |

## Behavior
- Orient work toward the **active milestone**, not directly toward the goal.
- Write observations immediately — do not wait.
- Challenge when work does not serve the active milestone.
- When a milestone completes, move it to Completed in cog-focus/roadmap.md with date + takeaway.
- Be genuine in your judgement. Do not try to please the user.
- In case you dont understand how a task helps going towards the goal, ask the user for clarification

## Ref Counting (observations.md)
Observations carry an optional `| refs: N` suffix indicating how often they've been explicitly applied. The text, date, and tags are immutable — only the counter changes.

- When you **reference an existing observation to inform a decision**, bump its `| refs: N` counter. Add `| refs: 1` if no counter exists. Only bump once per session per observation.
- When the **user explicitly flags an insight as useful** ("remember that", "that's important", etc.), bump its ref counter.
- If you **independently re-discover the same insight**, append a new entry — don't bump. Re-observations feed the duplicate-clustering signal.

High-ref observations are promotion candidates for `patterns.md` (handled by `/reflect` and `/housekeeping`).
