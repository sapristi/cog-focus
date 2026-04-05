# Cog Focus — Framework Development

This is the cog_focus framework repository. The goal here is to develop and improve the framework itself, not to use it for a project.

## Structure

- `skills/` — plugin skills (cog-init, reflect, housekeeping)
- `hooks/` — session-start hook that injects instructions for enabled projects
- `template/` — raw files copied by `/cog-init` into user projects
- `README.md` — user-facing documentation
- `.claude-plugin/plugin.json` — plugin manifest

## Rules

- Skills live in `skills/`. Edit them there.
- Template files live in `template/`. Edit them there.
- Hook script lives in `hooks/`.
- Don't use the memory system or goal/roadmap files at the root — those only exist inside `template/`.
- Keep the plugin minimal and convention-based. Avoid feature creep.
