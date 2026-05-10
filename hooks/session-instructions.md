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
- Write qualifying observations immediately — do not wait. (See *Observations: what to write* below for the filter.)
- Challenge when work does not serve the active milestone.
- When a milestone completes, move it to Completed in cog-focus/roadmap.md with date + takeaway.
- Be genuine in your judgement. Do not try to please the user.
- In case you dont understand how a task helps going towards the goal, ask the user for clarification

## Observations: what to write
Observation = something that should change a future decision. Fewer, sharper entries beat a journal.

Write when:
- A decision was made and the rationale isn't obvious from the diff (`[decision]`)
- Something surprised you in a way that generalizes beyond the current task (`[insight]`)
- A specific attempt failed in a way worth remembering (`[failed]`); a distilled negative rule (`[anti-pattern]`)
- A claim in `hot-memory.md` was confirmed or contradicted (`[hot-ref]` / `[hot-stale]`)

Skip when:
- It's a status update ("X installed", "Y shipped", "milestone done") — belongs in commits or `hot-memory.md`
- It restates something already in `patterns.md` or `hot-memory.md` — bump `| refs: N` instead (see Ref Counting)
- It's project-state that won't matter once the next milestone lands

**Length: ≤2 lines.** If you need more, write a design doc under `docs/` and let the observation point at it. Multi-paragraph entries indicate it's a spec, not an observation.

## Ref Counting (observations.md)
Observations carry an optional `| refs: N` suffix indicating how often they've been explicitly applied. The text, date, and tags are immutable — only the counter changes.

- When you **reference an existing observation to inform a decision**, bump its `| refs: N` counter. Add `| refs: 1` if no counter exists. Only bump once per session per observation.
- When the **user explicitly flags an insight as useful** ("remember that", "that's important", etc.), bump its ref counter.
- If you **independently re-discover the same insight**, append a new entry — don't bump. Re-observations feed the duplicate-clustering signal.

High-ref observations are promotion candidates for `patterns.md` (handled by `/reflect` and `/housekeeping`).

## Hot-Memory Feedback (observations.md)
Claims in `hot-memory.md` are only useful if they shape work. Tag observations to signal the connection:

- `[hot-ref]` — this observation confirms, restates, or applies a claim in `hot-memory.md`.
- `[hot-stale]` — this observation contradicts or supersedes a claim in `hot-memory.md`.

Tags stack with existing ones (e.g. `[decision, hot-stale]`). Apply only when the link is real — don't retrofit to inflate the signal.
