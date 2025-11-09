# Alfred Workflow: Capture Thread (tt-add)

1. Open Alfred Preferences → **Workflows**.
2. Click the `+` at the bottom → **Blank Workflow**.
3. Name it e.g. `Thread Capture`.

Inside the workflow:

1. Add a **Hotkey** trigger:
   - Set whatever you like, e.g. `⌃⌥T` (Ctrl + Option + T).
   - Set "Action" to "Pass through to workflow" or "No argument".

2. Add a **Run Script** action:
   - Language: `/bin/bash`
   - Script:

     ```bash
     /usr/bin/env tt-add
     ```

3. Connect the **Hotkey** node to the **Run Script** node.

Now, any time you're in ChatGPT, terminal, email, Obsidian, etc., hit your hotkey:

- Alfred runs `tt-add`
- `tt-add`:
  - captures current app + window title
  - prompts you for an optional description
  - appends a `- [ ] ...` entry to `threads.md`

Then you can use:

- `tt-list` in terminal to see your queue
- `tt-done N` to mark them complete
