# Cog Focus — Framework Development

This is the cog_focus framework repository. The goal here is to develop and improve the framework itself, not to use it for a project.

## Structure

- `template/` — the files that get copied when a user runs `cog-init`. This is the product.
- `bin/cog-init` — the init script users run to scaffold a new project.
- `README.md` — user-facing documentation.

## Rules

- Template files live in `template/`. Edit them there.
- Don't use the memory system or goal/roadmap files at the root — those only exist inside `template/`.
- The root `CLAUDE.md` (this file) is for framework development. The `template/CLAUDE.md` is what end users get.
- Keep the template minimal and convention-based. Avoid feature creep.
