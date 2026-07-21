---
name: housekeeping
description: Memory maintenance — archives old data, triages untriaged tasks, surfaces stale items, rebuilds archive index
user-invocable: true
---

## Guard

Check if `cog-focus/config.yaml` exists in the current directory. If it does not, tell the user:

"This project doesn't have cog-focus enabled. Run `/cog-init` to set it up."

Then stop — do not proceed with the rest of this skill.

Use this skill to perform memory housekeeping. Trigger if the user says "housekeeping", "clean up memory", "prune", "archive old data", or similar maintenance requests.

## Sub-agent dispatch

Steps marked **(sub-agent)** dispatch a `general-purpose` sub-agent rather than running inline. Rationale: the work produces verbose intermediate content (full file bodies, before/after diffs, moved entries) that the parent doesn't need to keep in context. Each dispatch:
- Names the exact files the sub-agent may touch — abort and return a paused status if asked to touch others.
- Returns one summary line (e.g. `compressed 4 entries`, `archived 23 entries to observations-2026.md`, `nothing to do`).

If a sub-agent reports `paused` or `failed`, surface the line and ask the user before retrying.

## 0. Reflect First (if stale)

Read `last_reflect` from `cog-focus/config.yaml`. If it is `never` or older than 1 day (compared to today's date), invoke the `/reflect` skill **before** continuing. Otherwise skip to §1.

Division of labor: reflect owns content decisions (observation condensation, progress assessment). Housekeeping enforces mechanical discipline on top — size caps, archival by count, task triage, archive index.

## 1. Sync Headers from Template

Plugin templates evolve (tag legend, format hints, length caps). Refresh project memory headers to match the current template; content stays untouched.

For each of `observations.md` and `patterns.md`:
1. Read the template at `${CLAUDE_PLUGIN_ROOT}/template/cog-focus/memory/<file>`.
2. Compare the leading block — the `# Title` line plus any `<!-- ... -->` comment lines immediately following, up to the first non-comment, non-blank line.
3. If different, replace that leading block in the project file. Preserve everything below.

Also sync the comment lines under `## Completed` in `roadmap.md` against `${CLAUDE_PLUGIN_ROOT}/template/cog-focus/roadmap.md`: the consecutive `<!-- ... -->` lines immediately under the `## Completed` heading. Don't touch any other section of roadmap.md.

**Obsolete files**: list files in `cog-focus/memory/` (excluding `archive/`, thread files, and `reflect-cursor.md`) that have no counterpart in `${CLAUDE_PLUGIN_ROOT}/template/cog-focus/memory/` — leftovers from removed architecture (e.g. `hot-memory.md`). For each, show its content briefly and ask the user whether to delete it; salvage anything with lasting value into `observations.md` first. Never delete without confirmation.

Skip silently if `$CLAUDE_PLUGIN_ROOT` is unset or a template file is missing. Note any header changes and deletions in the debrief.

## 2. Compress Completed Entries (sub-agent)

Enforces the ≤2-line rule on the `## Completed` section of `roadmap.md`. Dispatch:

> Read `cog-focus/roadmap.md`. In the `## Completed` section, find every entry whose source spans more than 2 lines (a bullet plus any indented continuation, sub-bullets, or `**Subtasks (record):**` blocks). For each over-long entry, rewrite it to fit the format `- YYYY-MM-DD: milestone name — 1-line takeaway`: preserve the date, keep the milestone name, condense the rest to one sentence focused on the *takeaway* (what was learned), and drop inline subtask records, file/commit references, and test counts. Touch only `cog-focus/roadmap.md`. Return one line: `compressed <N> entries` or `nothing to compress`.

## 3. Archive Observations (sub-agent)

Check observation count: `grep -c "^- " cog-focus/memory/observations.md`.

If ≤50, skip. Otherwise dispatch:

> Read `cog-focus/memory/observations.md`. The file is an append-only log of `- YYYY-MM-DD [tags]: ...` entries. Move all entries except the 30 most recent into year-grouped archive files at `cog-focus/memory/archive/observations-YYYY.md` (grouped by each entry's `YYYY-` prefix). When appending to an existing archive file, add at the end. When creating a new one, prepend a `# Year YYYY observations` title. Then remove the moved entries from the main file, leaving the header block intact. Touch only `cog-focus/memory/observations.md` and the archive files for the years involved. Return one line: `archived <N> entries to <comma-separated archive files>` or `nothing to archive`.

## 4. Promote High-Ref Observations

Scan `cog-focus/memory/observations.md` for entries with `| refs: N` where `N >= 3`.

For each qualifying entry:
1. If not already covered by an existing rule in `patterns.md`, distill it into a concise, actionable rule and add to `patterns.md` (respect the 50-line cap — compress existing rules if needed).
2. Remove the `| refs: N` suffix from the source observation. It graduated — the counter restarts from zero in case the observation keeps being useful beyond the pattern.

The observation text itself stays untouched. This step is additive to reflect's condensation (which also considers ref counts) — it catches high-ref accumulation when reflect isn't stale enough to trigger.

## 5. Triage & Surface Tasks

Read `cog-focus/roadmap.md`.

**Triage Untriaged items** — for each open item in the `Untriaged` section, ask the user one of:
- Which milestone does it belong to? (move it into that milestone's Subtasks)
- Is it legitimately cross-cutting? (leave it in Untriaged, note that it's ongoing)
- Should it be dropped?

Move confirmed items into their milestone's `Subtasks` block (create the block if absent). Leave cross-cutting items in place.

**Surface stale items** — open subtasks (anywhere in roadmap.md) older than 2 weeks: list with age and suggest a next action. Be direct.

## 6. Rebuild Archive Index (sub-agent)

Dispatch:

> Scan `cog-focus/memory/archive/*.md` (excluding `index.md` itself). For each file: count `^- ` entries, find the earliest and latest `YYYY-MM-DD` prefix, and write a one-sentence summary of what's archived (dominant themes/tags). Write the result to `cog-focus/memory/archive/index.md`:
>
> ```markdown
> # Archive Index
> <!-- Auto-generated by housekeeping. Do not edit. -->
> <!-- Last updated: YYYY-MM-DD -->
>
> | File | Date Range | Entries | Summary |
> |------|------------|---------|---------|
> ```
>
> Touch only `cog-focus/memory/archive/index.md`. Return one line: `index rebuilt: <N> archive files indexed` or `no archive files`.

## 7. Debrief

Summarize:
- What was archived/pruned/compressed (sub-agent results)
- Header changes from §1
- Untriaged items sorted and where they went
- Stale tasks surfaced
- Any issues found

Keep it concise. List every file modified.

## 8. Update Timestamp

Update `last_housekeeping` in `cog-focus/config.yaml` to the current date/time (ISO 8601, e.g. `2026-04-05T14:30:00`).
