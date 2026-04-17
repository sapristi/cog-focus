# Hot Memory
<!-- Rewrite freely. Keep under 50 lines. What matters right now for the goal. -->

## Current State (2026-04-18)

- **No active milestone.** Work mode is exploratory: architecture/plumbing for the plugin itself, dogfooding.
- **Plugin is self-hosted:** cog-focus runs on its own repo (see commit `8f42da4`).

## Recently Stabilized

- **One-surface task model:** `roadmap.md` holds milestones with `Subtasks:` blocks + `Untriaged` bucket. `action-items.md` removed. `/housekeeping` triages Untriaged → milestone.
- **Reflect/Housekeeping boundary:** reflect owns content (patterns, condensation, relevance). housekeeping owns mechanical discipline (size caps, archival, triage). Housekeeping chains `/reflect` when `last_reflect` is stale (>1 day).
- **Session instructions extracted:** `hooks/session-instructions.md`, loaded via `$(cat …)` in the SessionStart hook.
- **README has text diagrams** for session lifecycle and memory flows (no Mermaid).

## Watch

- Roadmap is empty. If drift continues without a milestone, evaluate whether to name one (candidates: "Plugin architecture stabilization", "Real-project dogfooding"). Don't force it.
- Only 2 observations total — too thin for thread detection. Patterns distilled above are provisional.
