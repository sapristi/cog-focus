1. Read `last_processed` from reflect-cursor.md. If `never`, read most recent 3 sessions (no time filter).
2. Otherwise, convert `last_processed` ISO 8601 to Unix milliseconds for DB comparison:
   ```bash
   SINCE_MS=$(date -d "$LAST_PROCESSED" +%s)000
   ```
3. Get the project ID for the current directory:
   ```bash
   sqlite3 ~/.local/share/opencode/opencode.db \
     "SELECT id FROM project WHERE worktree = '$(pwd)'"
   ```
4. List sessions for this project since last processed:
   ```bash
   sqlite3 ~/.local/share/opencode/opencode.db \
     "SELECT id, title, time_created FROM session
      WHERE project_id = '<project_id>' AND time_created > $SINCE_MS
      ORDER BY time_created DESC"
   ```
   (If `last_processed` is `never`, omit the `time_created >` filter and `LIMIT 3`.)
5. For each session, fetch user messages:
   ```bash
   sqlite3 ~/.local/share/opencode/opencode.db \
     "SELECT id, data FROM message
      WHERE session_id = '<session_id>'
      AND json_extract(data, '$.role') = 'user'
      ORDER BY time_created"
   ```
6. For each message, fetch text parts:
   ```bash
   sqlite3 ~/.local/share/opencode/opencode.db \
     "SELECT data FROM part
      WHERE message_id = '<message_id>'
      AND json_extract(data, '$.type') = 'text'"
   ```
7. For each user message, also read the assistant reply (next message with `role` = `'assistant'` after it in the same session) and its text parts — same part query as step 6.

**Tool use context**: When scanning assistant replies, tool-call parts show what the assistant *did*. This is useful for "broken promises" detection. Query `json_extract(data, '$.type') = 'tool'` from `part` to see tool invocations.

**After processing**, update `last_processed` in reflect-cursor.md to current ISO 8601 time.
