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

## 4. Enable cog-focus in settings

Check if `.claude/settings.json` exists.

- If it does not exist: create the `.claude/` directory and write `{ "cog-focus": { "enabled": true } }` to `.claude/settings.json`.
- If it exists: read it, merge `"cog-focus": { "enabled": true }` into the top-level JSON object, and write the file back, preserving all existing settings.

## 5. Git commit

Stage the new files and commit:

```
git add goal.md roadmap.md .gitignore memory/ .claude/settings.json
git commit -m "chore: initialize cog focus project"
```

## 6. Report

Tell the user which files were created and that `.claude/settings.json` was updated. End with:

"Cog Focus initialized. Edit `goal.md` to define your goal, then `roadmap.md` to set your first milestone."
