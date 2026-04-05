Initialize a Cog Focus project in the current directory.

## Guard Rails

1. Check if `CLAUDE.md` already exists in the current directory. If it does, warn the user that it exists and ask how they want to proceed.
2. Check if the current directory is a git repo. If not, ask the user if they want to run `git init`. Do not run it automatically unless the user explicitly asked for it.

## Find the Template

Locate the cog_focus template directory. Try these paths in order:
1. `$ARGUMENTS` if provided (user can pass a custom path)
2. `~/dev/cog_focus/template`

If none exist, tell the user to set the path: `/cog-init /path/to/cog_focus/template`

## Scaffold

Run:

```bash
cp -r <template_path>/ .
```

This copies CLAUDE.md, goal.md, roadmap.md, memory/, .claude/, and .gitignore into the current directory.

## After Copying

1. Run `git add -A && git commit -m "chore: initialize cog focus project"` to create the initial commit.
2. Tell the user: "Cog Focus initialized. Edit `goal.md` to define your goal, then `roadmap.md` to set your first milestone."
