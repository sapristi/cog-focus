---
name: cog-init
description: Initialize a Cog Focus project in the current directory — scaffolds goal, roadmap, and memory files
user-invocable: true
---

Initialize a Cog Focus project in the current working directory. Follow these steps in order:

## 1. Guard

Check if `goal.md` or `memory/` already exist in the current directory. If either exists, warn the user and ask whether to overwrite, skip existing files, or abort. Do not proceed until the user responds.

## 2. Git check

Run `git rev-parse --is-inside-work-tree` in the current directory. If the command fails (not a git repo), ask the user if they want to run `git init`. Do not run `git init` without explicit confirmation.

## 3. Copy template files

Run the following two commands to copy template files into the current directory:

```
cp -r "${CLAUDE_PLUGIN_ROOT}/template/goal.md" "${CLAUDE_PLUGIN_ROOT}/template/roadmap.md" "${CLAUDE_PLUGIN_ROOT}/template/.gitignore" .
cp -r "${CLAUDE_PLUGIN_ROOT}/template/memory" .
```

`CLAUDE_PLUGIN_ROOT` is an environment variable set by Claude Code pointing to the plugin's install directory.

## 4. Define the goal

Tell the user the scaffolding is done, then help them define their goal through a short conversation. Ask these questions one at a time, waiting for the user's answer before continuing:

1. **"What are you trying to accomplish?"** — Get a one-sentence goal.
2. **"Why does this matter? What changes when you succeed?"** — Get the motivation.
3. **"How will you know you're done? Give me 3-5 concrete criteria."** — Get success criteria.
4. **"Any constraints — time, scope, things you're explicitly NOT doing?"** — Get constraints.

After collecting all answers, write `goal.md` with the user's responses filled into the template sections (What, Why, Success Looks Like, Constraints). Show the user the result and ask if it looks right. Revise if needed.

## 5. Define the first milestones

Now help the user break the goal into milestones:

1. **"What's the first concrete step toward this goal?"** — This becomes the active milestone. Ask follow-ups to fill in the objective, open questions, and approach.
2. **"What comes after that? List 2-4 upcoming milestones — rough guesses are fine."** — These become the Upcoming section.

Write `roadmap.md` with the active milestone filled in and the upcoming milestones listed. Show the user the result and ask if it looks right. Revise if needed.

## 6. Git commit

Stage all files and commit:

```
git add goal.md roadmap.md .gitignore memory/
git commit -m "chore: initialize cog focus project"
```

## 7. Report

Tell the user Cog Focus is initialized and ready. Mention that:
- The session-start hook will now activate for this project
- They can run `/reflect` to review progress and `/housekeeping` to maintain memory files
- Goal and roadmap can always be edited directly as they learn more
