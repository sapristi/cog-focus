Use this skill for self-reflection and improvement. Trigger if the user says "reflect", "what have you learned", "how can you improve", or similar introspection requests.

**Take your time.** This is a deep session. Read broadly, cross-reference, and ACT on what you find. Leave things better than you found them.

## Purpose

Pattern recognition, memory maintenance, goal progress assessment.

## Orientation (run FIRST)

```bash
# What changed since last run?
find memory/ -type f -name "*.md" -mtime -1 | sort

# Entry counts for archival threshold
grep -c "^- " memory/observations.md memory/action-items.md 2>/dev/null
```

## Memory Files

Read on activation:
- `goal.md` (success criteria for progress check)
- `memory/reflect-cursor.md` (session path + cursor)
- `memory/observations.md`
- `memory/patterns.md`
- `memory/hot-memory.md`
- `memory/action-items.md`

## Process

### 1. Review Recent Sessions

Read `memory/reflect-cursor.md` for the session path and cursor.

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

### 3. Goal Progress Assessment

Read `goal.md` "Success Looks Like" criteria. For each criterion:
- Check observations and action-items for evidence of progress
- Rate: **on track** / **stalled** / **no signal**
- Note blockers or next actions needed

Report progress honestly. If there's no evidence of movement, say so.

### 4. Condensation Check

Scan `observations.md` for clusters of 3+ entries on the same theme/tag:
- Distill into a pattern → add/update `memory/patterns.md`
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
- Check if a thread file already exists in `memory/`
- If not, suggest: "Thread candidate: [topic] — [N] fragments across [date range]"
- Don't auto-create threads — suggest them

### 7. Act on Findings

Don't just log — *fix things*.

- New observations → append to `memory/observations.md` (max 5 per reflect pass, use `[meta]` tag)
- Pattern updates → edit `memory/patterns.md`
- Memory gaps → write to appropriate file
- Stale hot-memory → prune

### 8. Debrief

Compose a concise summary:
- *Goal progress* — status per success criterion
- *What I learned* — new patterns and insights
- *What I fixed* — memory gaps filled, corrections made
- *What to watch* — things to be mindful of going forward

**IMPORTANT**: List every file you modified and summarize the changes. If you made no changes in a step, state that explicitly.
