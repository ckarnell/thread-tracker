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
     cd "/Users/cohen/Documents/threadtracker"
     PYTHONPATH=. THREADS_FILE="$HOME/Documents/Obsidian Vault/Threads/threads.md" /Users/cohen/.local/bin/tt-add # Replace with the relevant paths. DON'T USE A KEY CORD THAT ALREADY EXISTS IN THE TERMINAL, e.g. don't use control+t
     ```
   - (Optional) Set "Show HUD Overlay" or notification if you want feedback.

8. Repeat the process for a second command, e.g. `⌃⌥L`. In the configuration panel, set:
   - **Shell Script**:
     ```bash
     PYTHONPATH=. THREADS_FILE="$HOME/Documents/Obsidian Vault/Threads/threads.md" /Users/cohen/.local/bin/tt-list # Replace with the relevant paths

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

---

## Unified Add/Done: `tt-combo`

You can also use the new `tt-combo` command, which combines adding and completing threads in one step.

- When triggered, it shows your open threads, numbered just like `tt-done`.
- It prompts you:  
  _"Enter a number to mark a thread as done, or type a new thread description to add it:"_
- If you enter a number, that thread is marked as done.
- If you enter a new description, it is added as a new thread (with app/window context, just like `tt-add`).
- Pressing **Escape** or clicking **Cancel** will close the dialog without making changes.

### Example BetterTouchTool Setup

1. Add a new shortcut (e.g. `⌃⌥C`).
2. Set the action to **"Execute Shell Script / Task"**.
3. Use this shell script:
   ```bash
   cd "/Users/cohen/Documents/threadtracker"
   PYTHONPATH=. THREADS_FILE="$HOME/Documents/Obsidian Vault/Threads/threads.md" /Users/cohen/.local/bin/tt-combo
   ```
4. (Optional) Set a HUD overlay or notification for feedback.

Now you can add or complete threads with a single hotkey and dialog!
