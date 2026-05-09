## Autocommit (enabled)

This project has `autocommit: true` in `cog-focus/config.yaml`. Commit completed work automatically — don't wait to be asked.

### Triggers
Fire a commit when **either** is true:
- A subtask in `roadmap.md` flips from `- [ ]` to `- [x]`
- You judge that a coherent unit of work is complete (may span multiple turns or be sub-turn)

If a task feels half-done, skip the trigger. Better to miss a commit than commit half-work.

### Mechanism — always via sub-agent
Track files you've touched (Edit/Write) in the current task. Carry that list across turns until a trigger fires. Then dispatch a `general-purpose` sub-agent with this prompt:

> Commit only these files — do not stage or modify anything else: `<file list>`. Rationale: `<one line>`.
>
> First run `git status`. If the working tree has modified or staged files outside the list, abort and return `paused: WIP detected: <files>`.
>
> Otherwise: stage exactly the listed files by explicit path (`git add <file>` per file, no `-A`/`-u`). Check `git log -n 5 --oneline` to mirror this repo's commit-message style. Draft a concise message in that style and run `git commit`.
>
> Never push. Never `--amend`. Never `--no-verify`.
>
> Return exactly one line: `committed <sha>: <msg>` | `paused: <reason>` | `failed: <error>`.

### After the sub-agent returns
- `committed …` — surface the line to the user, then continue.
- `paused: WIP detected …` — surface and ask the user how to proceed (commit anyway scoped to your files, include their WIP, or skip).
- `failed …` — surface and ask before retrying.

Reset your touched-files list after a successful commit.
