# Threads Tracker

Tools for capturing and managing open threads using Markdown checklists.

## Overview
Threads Tracker keeps a running list of open TODOs in a plain-text Markdown file. The
command-line helpers let you capture what you are working on, review the queue, and mark
items done without leaving the keyboard. It is designed to be quick to invoke from
Alfred or the terminal while you are in the middle of another task.

## Features
- **`tt-add`** captures the front-most macOS application + window title, prompts for an
  optional note, and appends a `- [ ]` checklist item with an ISO8601 timestamp.
- **`tt-list`** prints the open checklist items (those that still contain `- [ ]`).
- **`tt-done N`** converts the Nth open item to `- [x]` so you can keep a history of what
  was completed.
- **`tjob` shell helper** (see [`shell/tjob.zsh`](shell/tjob.zsh)) wraps a long-running
  command, logging it to the threads file before execution.
- Optional [Alfred workflow](alfred/create_workflow.md) so you can fire off `tt-add`
  with a hotkey from anywhere on macOS.

> **Platform note:** `tt-add` relies on `osascript`, so capturing the active application
> and window title currently only works on macOS. The other commands are cross-platform.

## Installation
1. Clone the repository wherever you keep dotfiles/tools.
2. Run the install script:
   ```bash
   ./install.sh
   ```
   This ensures the scripts are executable and symlinks `tt-add`, `tt-list`, and
   `tt-done` into `~/.local/bin`. If that directory is not already on your `PATH`, the
   installer reminds you how to add it to your shell configuration.
3. (Optional) Source `shell/tjob.zsh` from your shell config if you want the `tjob`
   helper:
   ```bash
   source /path/to/thread-tracker/shell/tjob.zsh
   ```

## Configuration
By default, Threads Tracker stores entries in `~/threads.md`. You can override the
location in two ways:

1. Set the `THREADS_FILE` environment variable, e.g.
   ```bash
   export THREADS_FILE="$HOME/Documents/team-threads.md"
   ```
2. Create `~/.threadstrc` containing a `THREADS_FILE=/path/to/file.md` line. Comments
   (`# ...`) and blank lines are ignored.

Whenever a command runs it ensures the file exists, creating it with a heading `# Open
Threads` if necessary.

## Usage
```bash
# Capture the current context + optional note
$ tt-add
Added thread:
  Safari — Research API docs — Capture error handling cases
Stored in: /Users/you/threads.md

# List open items in order of appearance
$ tt-list
Open threads:
1. Safari — Research API docs — Capture error handling cases
2. Terminal — Implement response caching layer

# Mark the first open item complete (preserves the text as a checked box)
$ tt-done 1
Marked thread #1 as done.
```

The Markdown file remains human-editable, so you can reorder, annotate, or archive items
by hand whenever you like.

### Alfred hotkey (optional)
If you use Alfred, follow the instructions in
[`alfred/create_workflow.md`](alfred/create_workflow.md) to bind `tt-add` to a hotkey.
This lets you log a thread without touching the terminal.

## Development & Testing
These scripts are plain Python, so the simplest syntax check is to byte-compile them:
```bash
python3 -m compileall bin common.py
```
(If you previously saw `Can't list 'threads-tracker'`, the directory name in the old
command was a typo—use `thread-tracker` or the explicit paths above.)

## Roadmap / Ideas
- Export statistics (e.g., items opened vs. closed per week)
- Cross-platform capture for non-macOS systems
- Lightweight TUI for re-ordering or annotating threads

PRs and ideas are welcome!
