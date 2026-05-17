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
   (If `last_processed` is `never`, omit the `time_created >` filter and add `LIMIT 3`.)

5. For each session, fetch user messages — extract only the text content, skip array-type content (tool results):
   ```bash
   sqlite3 ~/.local/share/opencode/opencode.db \
     "SELECT id, json_extract(data, '$.content') FROM message
      WHERE session_id = '<session_id>'
      AND json_extract(data, '$.role') = 'user'
      AND json_type(data, '$.content') = 'text'
      ORDER BY time_created"
   ```
   The `json_type(…, '$.content') = 'text'` filter excludes user messages whose content is an array (tool results). Those are feedback from tool executions, not actual user messages.

6. For each (user or assistant) message, fetch text parts — extract only the `text` field:
   ```bash
   sqlite3 ~/.local/share/opencode/opencode.db \
     "SELECT json_extract(data, '$.text') FROM part
      WHERE message_id = '<message_id>'
      AND json_extract(data, '$.type') = 'text'"
   ```

7. For each user message, also read the assistant reply (next message with `role` = `'assistant'` after it in the same session):
   ```bash
   sqlite3 ~/.local/share/opencode/opencode.db \
     "SELECT id FROM message
      WHERE session_id = '<session_id>'
      AND json_extract(data, '$.role') = 'assistant'
      AND time_created > (SELECT time_created FROM message WHERE id = '<user_message_id>')
      ORDER BY time_created
      LIMIT 1"
   ```
   Then extract its text parts and tool parts using the same queries as steps 6 and below.

**Tool use context**: When scanning assistant replies, tool-call parts show what the assistant *did*. This is useful for "broken promises" detection. Extract tool invocations with:
   ```bash
   sqlite3 ~/.local/share/opencode/opencode.db \
     "SELECT json_extract(data, '$.tool') FROM part
      WHERE message_id = '<assistant_message_id>'
      AND json_extract(data, '$.type') = 'tool'"
   ```

**IMPORTANT — Clean extraction**: Never `SELECT data` directly from either `message` or `part` — the raw JSON blobs contain metadata (summaries, diffs, usage stats, model info) that is noisy and irrelevant for reflection. Always use `json_extract(data, '$.field')` to pull out only the fields you need.

**After processing**, update `last_processed` in reflect-cursor.md to current ISO 8601 time.
