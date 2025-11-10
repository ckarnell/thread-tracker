# Threads Tracker

Tools for capturing and managing open threads using Markdown checklists.

## Overview
Threads Tracker keeps a running list of open TODOs in a plain-text Markdown file. The
command-line helpers let you capture what you’re working on, review the queue, and mark
items done without leaving the keyboard. It’s designed to be quick to invoke from
Alfred or the terminal while you’re in the middle of another task.

## Features
- **`tt-add`** captures the front-most macOS application + window title, prompts for an
  optional note, and appends a `- [ ]` checklist item with an ISO8601 timestamp.
- **`tt-list`** prints the open checklist items (those that still contain `- [ ]`).
- **`tt-done N`** converts the Nth open item to `- [x]` so you can keep a history of what
  was completed.
- **`tt-combo`** shows open threads, allows you to close or open a new one, allows you to
  open a link to a thread if applicable.
- **`tjob` shell helper** (see [`shell/tjob.zsh`](shell/tjob.zsh)) wraps a long-running
  command, logging it to the threads file before execution.
- Optional [Alfred workflow](alfred/create_workflow.md) so you can trigger `tt-add`
  with a hotkey from anywhere on macOS.

> **Platform note:** `tt-add` relies on `osascript`, so capturing the active application
> and window title currently only works on macOS. The other commands are cross-platform.

---

## Installation

1. Clone the repository wherever you keep your tools or dotfiles:
   ```bash
   git clone https://github.com/yourname/thread-tracker.git
   cd thread-tracker
   ```

2. Run the install script:
   ```bash
   ./install.sh
   ```
   This:
   - Ensures the `tt-add`, `tt-list`, and `tt-done` scripts are executable.
   - Creates symlinks in `~/.local/bin/` for convenient access from anywhere.
   - Reminds you how to add that directory to your `PATH` if it’s not already there.

3. Verify that it worked:
   ```bash
   tt-list
   ```
   If you see an error like `command not found`, add this to your shell config (e.g. `~/.zshrc` or `~/.bashrc`):
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```
   Then restart your shell or run `source ~/.zshrc`.

4. (Optional) Enable the `tjob` helper:
   ```bash
   source /path/to/thread-tracker/shell/tjob.zsh
   ```

---

## Quickstart

After installation, try these commands:

```bash
# Capture your current window + optional note
tt-add

# List your open threads
tt-list

# Mark the first open thread complete
tt-done 1
```

This creates a file at `~/threads.md` containing a Markdown checklist.  
You can open it manually in any editor — it’s just text.

---

## Configuration

By default, Threads Tracker stores entries in `~/threads.md`. You can override this:

1. Set the `THREADS_FILE` environment variable:
   ```bash
   export THREADS_FILE="$HOME/Documents/team-threads.md"
   ```
2. Or create a config file at `~/.threadstrc`:
   ```bash
   THREADS_FILE=/path/to/custom/file.md
   ```

Whenever a command runs, it ensures the file exists, creating it with a `# Open Threads`
heading if necessary.

---

## Example

```bash
$ tt-add
Added thread:
  Safari — Research API docs — Capture error handling cases
Stored in: /Users/you/threads.md

$ tt-list
Open threads:
1. Safari — Research API docs — Capture error handling cases
2. Terminal — Implement response caching layer

$ tt-done 1
Marked thread #1 as done.
```

The Markdown file remains human-editable, so you can reorder or annotate items at will.

---

## Alfred Hotkey (Optional)

If you use Alfred, see
[`alfred/create_workflow.md`](alfred/create_workflow.md) for setup instructions.  
This allows you to log a thread instantly via a keyboard shortcut.

---

## Development & Testing

To check syntax or validate all scripts compile cleanly:
```bash
python3 -m compileall bin common.py
```

---

## Roadmap / Ideas
- Export usage statistics (items opened vs. closed per week)
- Cross-platform capture for non-macOS systems
- Lightweight TUI for reordering or annotating threads

PRs and ideas are welcome!

