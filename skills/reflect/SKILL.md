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
find cog-focus/memory/ cog-focus/roadmap.md -type f -name "*.md" -mtime -1 | sort

# Observation count for archival threshold
grep -c "^- " cog-focus/memory/observations.md 2>/dev/null
```

## Memory Files

Read on activation:
- `cog-focus/roadmap.md` (Goal with success criteria; active milestone, subtasks, untriaged, completed)
- `cog-focus/memory/reflect-cursor.md` (session path + cursor)
- `cog-focus/memory/observations.md`
- `cog-focus/memory/patterns.md`
- `cog-focus/memory/hot-memory.md`

## Process

### 1. Review Recent Sessions

Read `cog-focus/memory/reflect-cursor.md` for the session path and cursor.

<!-- OPENCODE-PATCH:session-source:start -->
1. Get `session_path` from reflect-cursor.md
2. Glob for `*.jsonl` in that directory
3. Only read sessions modified **after** `last_processed` (if `never`, read most recent 3)
4. User messages: `type: "user"` where `message.content` is a **string** (arrays are tool results — skip)
5. Assistant messages: `type: "assistant"` with `message.content` items having `type: "text"`

**After processing**, update `last_processed` in reflect-cursor.md.
<!-- OPENCODE-PATCH:session-source:end -->

**Look for:**
- Unresolved threads — questions asked but never answered
- Broken promises — "I'll do X" that never happened
- Repeated friction — same question asked multiple ways, user corrections
- Memory gaps — information discussed but never saved
- Missed cues — things the user had to repeat

### 2. Cross-Reference Memory

Check if findings are already captured:
- Commitments tracked as subtasks under the right milestone in `roadmap.md` (or in `Untriaged` if unscoped)?
- Learnings in `observations.md`?
- Patterns distilled in `patterns.md`?

**Consistency check**: Read `hot-memory.md`. For factual claims, verify against source files. Fix hot-memory if stale.

### 3. Milestone & Goal Progress Assessment

**Active milestone** (from `cog-focus/roadmap.md`):
- Is the current approach working? Rate: **on track** / **stalled** / **blocked**
- Scan its Subtasks: what's checked, what's stalled, what's been added recently? Concrete signal for progress.
- If stalled: suggest concrete next action or milestone revision
- If the milestone seems done: flag it for completion and remember this — step 9 will prompt the user to pick what's next. Don't act on the transition yet.

**Goal-level check** (from `cog-focus/roadmap.md` Goal section, "Success Looks Like"):
- For each criterion, check observations for evidence of progress
- Rate: **on track** / **stalled** / **no signal**
- Flag if work has drifted away from the goal — milestones should serve it

**Roadmap health**:
- Are upcoming milestones still the right next steps given what you've learned?
- Suggest reordering, splitting, or adding milestones if evidence supports it

Report progress honestly. If there's no evidence of movement, say so.

### 4. Condensation Check

Three promotion signals into `patterns.md`:

- **Clustering**: clusters of 3+ entries on the same theme/tag in `observations.md` → distill into a pattern.
- **Ref count**: individual observations with `| refs: N` where `N >= 3` → distill into a pattern even without a theme cluster. High refs mean the observation is actively load-bearing.
- **Hot-memory stabilization**: scan `hot-memory.md` for lines that have generalized into timeless rules — claims that survive across milestones rather than describe project-state (the "carried priors" shape). Promote each into `patterns.md` and replace the hot-memory line with a one-line pointer (`see patterns.md: <rule>`) or remove it if the pattern covers it fully. This enforces hot-memory rule #4 ("promote when stable").

For all paths:
- Add/update `cog-focus/memory/patterns.md`
- Don't delete observations — they stay as raw record. Hot-memory lines, by contrast, get pointered or removed once promoted (hot-memory is volatile by design).
- **Patterns cap: 50 lines.** If near cap, compress (merge overlapping rules, drop examples)
- Entries must be timeless rules — "what to do" not "what happened"
- Skip if the insight is already covered by an existing pattern

Reflect does not clear `| refs: N` suffixes — housekeeping handles that mechanical step.

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

### 9. Milestone Transition

If — and only if — step 3 flagged the active milestone as done, ask the user to choose what's next. Present three options:

1. **Pick the next milestone from `Upcoming`** — list the upcoming milestones (with their one-line descriptions) so the user can pick one. The chosen milestone moves into `Active Milestone`.
2. **Choose another / add a new milestone** — the user names a different milestone (existing or new); draft its `Objective`, `Open questions`, `Approach`, and initial `Subtasks` from what reflect surfaced, then confirm before writing.
3. **Do nothing** — leave `Active Milestone` empty (or unchanged) for now.

On options 1 or 2, edit `cog-focus/roadmap.md`:
- Append the completed milestone to `Completed` using `- YYYY-MM-DD: milestone name — 1-line takeaway` (takeaway = what you learned, not what you did).
- Replace `Active Milestone` with the new one in the full milestone format (Objective / Open questions / Approach / Subtasks).
- Remove the new milestone from `Upcoming` if it came from there.

On option 3, still append the completed milestone to `Completed` and clear `Active Milestone` to `None — exploring and iterating as needs arise.` (or leave the previous one if the user wants to keep working it).

If step 3 did not flag the milestone as done, skip this step entirely — no prompt, no edits.

### 10. Update Timestamp

Update `last_reflect` in `cog-focus/config.yaml` to the current date/time (ISO 8601, e.g. `2026-04-05T14:30:00`).

### 11. Propose Commit

If this reflect pass modified any files (see the Debrief list), ask the user whether to commit them. Phrase it as a single yes/no, and list the files so they know what's in scope.

If the user accepts, dispatch a `general-purpose` sub-agent with this prompt:

> Commit only these files — do not stage or modify anything else: `<file list>`. Rationale: `/reflect` pass on `<today's date>`.
>
> Stage exactly the listed files by explicit path (`git add <file>` per file, no `-A`/`-u`). If any of those files are not actually modified per `git status`, skip them. Leave every other modified or staged file in the working tree untouched — even if it looks related.
>
> Check `git log -n 5 --oneline` to mirror this repo's commit-message style. Draft a concise message in that style (subject something like `chore(reflect): <one-line summary>`) and run `git commit`.
>
> Never push. Never `--amend`. Never `--no-verify`.
>
> Return exactly one line: `committed <sha>: <msg>` | `nothing to commit` | `failed: <error>`.

Surface the sub-agent's result line to the user. If the user declines, say so and stop — do not stage or commit anything.

Skip this step if reflect made no file changes.

## Threads

When a topic keeps coming up across observations, raise it into a **thread** — a synthesis file that pulls scattered fragments into a coherent narrative.

Thread files live in `cog-focus/memory/` (e.g., `cog-focus/memory/deployment-strategy.md`). Structure:
- **Current State** — what's true right now (rewrite freely)
- **Timeline** — dated entries, append-only, full detail preserved
- **Insights** — patterns, learnings, what's different this time

A thread gets raised when a topic appears in 3+ observations across 2+ weeks, or when the user says "raise X" or "thread X". Threads reference observations by date. One file forever, never condensed.
