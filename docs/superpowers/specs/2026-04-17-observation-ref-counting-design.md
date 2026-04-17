# Observation Ref Counting — Design Spec

## Problem

Useful observations have no way to surface over time. Claude may silently reference an old observation to inform a decision, but that usage is invisible. The only existing feedback loop is implicit: if Claude re-discovers the same insight, it appends a duplicate, and reflect's condensation step may eventually cluster duplicates into a pattern. But "quiet usage" (reading and applying without re-stating) leaves no trace.

## Solution

Add explicit reference counters to observations. Combined with the existing duplicate-as-signal mechanism, this gives two complementary promotion paths into patterns.md:

1. **Explicit refs** — Claude reads and applies an existing observation, bumps a counter on that line
2. **Implicit refs (duplicates)** — Claude independently re-discovers the same insight, appends a new entry

Housekeeping and reflect use both signals to decide what gets promoted to patterns.md.

## Design

### Observation format

Current:
```
- YYYY-MM-DD [tags]: observation text
```

New (optional suffix, added on first reference):
```
- YYYY-MM-DD [tags]: observation text | refs: 3
```

- `| refs: N` is omitted when an observation has never been explicitly referenced (zero refs)
- The observation text, date, and tags remain immutable — only the ref counter changes

### Edit pattern change

observations.md moves from "append-only" to "append-only + ref counter edits." No other edits to existing entries are permitted.

### Ref incrementing rules

Added to the behavior instructions injected by the session-start hook:

- When you reference an existing observation to inform a decision, bump its `| refs: N` counter. Add `| refs: 1` if no counter exists. Only bump once per session per observation.
- When the user explicitly flags an insight as useful ("remember that", "that's important", etc.), bump its ref counter.
- If you independently re-discover the same insight, append as a new entry — don't bump. It's a genuine re-observation and contributes to the duplicate clustering signal.

### Housekeeping changes

New promotion step added to the housekeeping skill:

1. Scan observations.md for entries with `refs >= 3`
2. For each qualifying entry, distill it into a concise, actionable rule
3. Add to patterns.md (if not already covered by an existing pattern)
4. Remove the `| refs: N` suffix from the source observation (it graduated — counter restarts from zero in case it keeps being useful beyond the pattern)

This is additive — existing housekeeping behavior (archival, pruning) is unchanged.

### Reflect changes

Reflect's condensation step (step 4) now considers both signals:

- **Existing**: clusters of 3+ entries on the same theme/tag get distilled into a pattern
- **New**: entries with high ref counts (>= 3) are flagged as promotion candidates, even without theme clustering

Both paths produce the same output: a distilled rule in patterns.md.

## What changes (file-by-file)

| File | Change |
|------|--------|
| `hooks/session-start` | Add ref-counting behavior rules to injected instructions; update edit pattern table for observations.md |
| `skills/housekeeping/SKILL.md` | Add ref-driven promotion step |
| `skills/reflect/SKILL.md` | Extend condensation step to consider ref counts |
| `template/cog-focus/memory/observations.md` | No change (format is backwards-compatible) |

## What does NOT change

- No new files created
- patterns.md role, format, and 50-line cap unchanged
- Session-start loading list unchanged (goal, roadmap, hot-memory, patterns)
- Template structure unchanged
- Archiving behavior unchanged — archived observations keep their ref counts
