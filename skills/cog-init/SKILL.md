---
name: cog-init
description: Initialize a Cog Focus project in the current directory — scaffolds goal, roadmap, and memory files
user-invocable: true
---

Initialize a Cog Focus project in the current working directory. Follow these steps in order:

## 1. Guard

Check if `cog-focus/` directory already exists in the current directory. If it does, warn the user that cog-focus is already initialized and ask whether to reinitialize (overwrite) or abort. Do not proceed until the user responds.

## 2. Git check

Run `git rev-parse --is-inside-work-tree` in the current directory. If the command fails (not a git repo), ask the user if they want to run `git init`. Do not run `git init` without explicit confirmation.

## 3. Copy template files

Before copying, check if `cog-focus/` already exists in the current directory. If it does, list its contents and ask the user whether to overwrite or skip. Do not overwrite without explicit confirmation.

Then copy the template directory:

```
cp -r "${CLAUDE_PLUGIN_ROOT}/template/cog-focus" .
```

`CLAUDE_PLUGIN_ROOT` is an environment variable set by Claude Code pointing to the plugin's install directory.

## 4. Define the goal

Tell the user the scaffolding is done, then help them define their goal through a short conversation. Ask these questions one at a time, waiting for the user's answer before continuing. Tell the user upfront they can **skip** any question that isn't pertinent (e.g. say "skip" or "n/a") — not every project needs all of them.

1. **"What are you trying to accomplish?"** — Get a one-sentence goal.
2. **"Why does this matter? What changes when you succeed?"** — Get the motivation.
3. **"How will you know this is working? Either concrete done criteria (if scoped), or signals of ongoing usefulness (if open-ended) — a few examples either way."** — Get success criteria, adapted to project shape.
4. **"If someone asked in 3 months whether this was worth it, what would you point to?"** — Get a concrete usefulness signal (especially useful for open-ended projects, but works for both).
5. **(Only if not already clear from Q1–Q4)** **"What shape is this — a tool you use, a library others use, research, exploration, something else?"** — Clarifies the success mode (self-use vs. shipped vs. exploratory) so future sessions know the audience. Skip if earlier answers already make this obvious.
6. **"Any constraints — time, scope, things you're explicitly NOT doing?"** — Get constraints.

After collecting answers, fill in the **Goal** section at the top of `cog-focus/roadmap.md` with the user's responses (What, Why, Success Looks Like, Constraints). Fold the answers to Q3, Q4, and Q5 together under **Success Looks Like**. Skipped questions → leave that subsection empty or write "None" / "Open-ended — see notes above". Keep the `<!-- LOCKED -->` marker intact. Show the user the result and ask if it looks right. Revise if needed.

## 5. Define the first milestones

Now help the user break the goal into milestones:

1. **"What's the first concrete step toward this goal?"** — This becomes the active milestone. Ask follow-ups to fill in the objective, open questions, and approach.
2. **"What comes after that? List 2-4 upcoming milestones — rough guesses are fine."** — These become the Upcoming section.

Fill in the **Active Milestone** and **Upcoming** sections of `cog-focus/roadmap.md`. Show the user the result and ask if it looks right. Revise if needed.

## 6. Report

Tell the user Cog Focus is initialized and ready. Mention that:
- The session-start hook will now activate for this project
- They can run `/reflect` to review progress and `/housekeeping` to maintain memory files
- Goal and roadmap can always be edited directly as they learn more
