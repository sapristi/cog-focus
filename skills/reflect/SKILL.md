---
name: reflect
description: Deep self-reflection — mines sessions, condenses patterns, checks goal progress, maintains memory health
user-invocable: true
---

## Guard

Check if `cog-focus/config.yaml` exists in the current directory. If it does not, tell the user:

"This project doesn't have cog-focus enabled. Run `/cog-init` to set it up."

Then stop — do not proceed with the rest of this skill.

Use this skill for self-reflection and improvement. Trigger if the user says "reflect", "what have you learned", "how can you improve", or similar introspection requests.

**Take your time.** This is a deep session. Read broadly, cross-reference, and ACT on what you find. Leave things better than you found them.

## Purpose

Pattern recognition, memory maintenance, goal progress assessment.

## Orientation (run FIRST)

```bash
# What changed since last run?
find cog-focus/memory/ -type f -name "*.md" -mtime -1 | sort

# Entry counts for archival threshold
grep -c "^- " cog-focus/memory/observations.md cog-focus/memory/action-items.md 2>/dev/null
```

## Memory Files

Read on activation:
- `cog-focus/goal.md` (success criteria for progress check)
- `cog-focus/roadmap.md` (active milestone and completed milestones)
- `cog-focus/memory/reflect-cursor.md` (session path + cursor)
- `cog-focus/memory/observations.md`
- `cog-focus/memory/patterns.md`
- `cog-focus/memory/hot-memory.md`
- `cog-focus/memory/action-items.md`

## Process

### 1. Review Recent Sessions

Read `cog-focus/memory/reflect-cursor.md` for the session path and cursor.

1. Get `session_path` from reflect-cursor.md
2. Glob for `*.jsonl` in that directory
3. Only read sessions modified **after** `last_processed` (if `never`, read most recent 3)
4. User messages: `type: "user"` where `message.content` is a **string** (arrays are tool results — skip)
5. Assistant messages: `type: "assistant"` with `message.content` items having `type: "text"`

**After processing**, update `last_processed` in reflect-cursor.md.

**Look for:**
- Unresolved threads — questions asked but never answered
- Broken promises — "I'll do X" that never happened
- Repeated friction — same question asked multiple ways, user corrections
- Memory gaps — information discussed but never saved
- Missed cues — things the user had to repeat

### 2. Cross-Reference Memory

Check if findings are already captured:
- Commitments tracked in `action-items.md`?
- Learnings in `observations.md`?
- Patterns distilled in `patterns.md`?

**Consistency check**: Read `hot-memory.md`. For factual claims, verify against source files. Fix hot-memory if stale.

### 3. Milestone & Goal Progress Assessment

**Active milestone** (from `cog-focus/roadmap.md`):
- Is the current approach working? Rate: **on track** / **stalled** / **blocked**
- If stalled: suggest concrete next action or milestone revision
- If the milestone seems done: flag it for completion and suggest promoting the next one

**Goal-level check** (from `cog-focus/goal.md` "Success Looks Like"):
- For each criterion, check observations for evidence of progress
- Rate: **on track** / **stalled** / **no signal**
- Flag if work has drifted away from the goal — milestones should serve it

**Roadmap health**:
- Are upcoming milestones still the right next steps given what you've learned?
- Suggest reordering, splitting, or adding milestones if evidence supports it

Report progress honestly. If there's no evidence of movement, say so.

### 4. Condensation Check

Scan `observations.md` for clusters of 3+ entries on the same theme/tag:
- Distill into a pattern → add/update `cog-focus/memory/patterns.md`
- Don't delete observations — they stay as raw record
- **Patterns cap: 50 lines.** If near cap, compress (merge overlapping rules, drop examples)
- Entries must be timeless rules — "what to do" not "what happened"

### 5. Hot-Memory Relevance

Review `hot-memory.md`:
- **Promote**: pattern heating up → add to hot-memory
- **Demote**: item gone quiet (no references in 2+ weeks) → remove
- Goal: hot-memory = what matters *right now*

### 6. Detect Thread Candidates

Scan observations for topics appearing across 3+ dates or spanning 2+ weeks. For each:
- Check if a thread file already exists in `cog-focus/memory/`
- If not, suggest: "Thread candidate: [topic] — [N] fragments across [date range]"
- Don't auto-create threads — suggest them

### 7. Act on Findings

Don't just log — *fix things*.

- New observations → append to `cog-focus/memory/observations.md` (max 5 per reflect pass, use `[meta]` tag)
- Pattern updates → edit `cog-focus/memory/patterns.md`
- Memory gaps → write to appropriate file
- Stale hot-memory → prune

### 8. Debrief

Compose a concise summary:
- *Milestone progress* — active milestone status + any suggested changes
- *Goal progress* — status per success criterion
- *What I learned* — new patterns and insights
- *What I fixed* — memory gaps filled, corrections made
- *What to watch* — things to be mindful of going forward

**IMPORTANT**: List every file you modified and summarize the changes. If you made no changes in a step, state that explicitly.

### 9. Update Timestamp

Update `last_reflect` in `cog-focus/config.yaml` to the current date/time (ISO 8601, e.g. `2026-04-05T14:30:00`).

## Threads

When a topic keeps coming up across observations, raise it into a **thread** — a synthesis file that pulls scattered fragments into a coherent narrative.

Thread files live in `cog-focus/memory/` (e.g., `cog-focus/memory/deployment-strategy.md`). Structure:
- **Current State** — what's true right now (rewrite freely)
- **Timeline** — dated entries, append-only, full detail preserved
- **Insights** — patterns, learnings, what's different this time

A thread gets raised when a topic appears in 3+ observations across 2+ weeks, or when the user says "raise X" or "thread X". Threads reference observations by date. One file forever, never condensed.
