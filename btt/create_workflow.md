# BetterTouchTool: Capture Thread (tt-add) via Hotkey

1. Open **BetterTouchTool**.

2. In the left sidebar, select **Keyboard Shortcuts** (or **Touch Bar** if you prefer).

3. Click **Add New Shortcut or Key Sequence**.

4. In the new shortcut row:
   - Click the **Shortcut** field and press your desired hotkey, e.g. `⌃⌥T` (Ctrl + Option + T).

5. With the shortcut selected, click **Attach Action**.

6. In the action search, type **"Execute Shell Script / Task"** and select it.

7. In the configuration panel, set:
   - **Shell Script**:
     ```bash
     /usr/bin/env tt-add
     ```
   - (Optional) Set "Show HUD Overlay" or notification if you want feedback.

8. Repeat the process for a second command, e.g. `⌃⌥L`. In the configuration panel, set:
   - **Shell Script**:
     ```bash
     /usr/bin/env tt-list
     open "obsidian://open?vault=Obsidian%20Vault&file=Threads/threads" # This is optional, include if you use Obsidian
     ```
   - (Optional) Set "Show HUD Overlay" or notification if you want feedback.

9. (Optional) Name your shortcut, e.g. `Thread Capture`.

Now, any time you're in ChatGPT, terminal, email, Obsidian, etc., hit your hotkey:

- BetterTouchTool runs `tt-add`
- `tt-add`:
  - captures current app + window title
  - prompts you for an optional description
  - appends a `- [ ] ...` entry to `threads.md`

Then you can use:

- `tt-list` in terminal to see your queue
- `tt-done N` to mark them complete
