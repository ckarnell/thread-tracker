import os
from pathlib import Path
from typing import List, Tuple, Optional

DEFAULT_THREADS_FILE = os.path.expanduser("~/threads.md")
CONFIG_FILE = os.path.expanduser("~/.threadstrc")


def parse_config_file() -> Optional[str]:
    if not os.path.exists(CONFIG_FILE):
        return None

    threads_file = None
    with open(CONFIG_FILE, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if line.startswith("THREADS_FILE="):
                value = line.split("=", 1)[1].strip().strip('"').strip("'")
                threads_file = os.path.expanduser(value)
    return threads_file


def get_threads_file() -> str:
    # 1. Env var
    env = os.environ.get("THREADS_FILE")
    if env:
        return os.path.expanduser(env)

    # 2. Config file
    cfg = parse_config_file()
    if cfg:
        return cfg

    # 3. Default
    return DEFAULT_THREADS_FILE


def ensure_threads_file_exists() -> str:
    path = Path(get_threads_file())
    if not path.exists():
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            f.write("# Open Threads (close them with tt-done N)\n\n")
    return str(path)


def load_threads_lines() -> List[str]:
    path = ensure_threads_file_exists()
    with open(path, "r", encoding="utf-8") as f:
        return f.readlines()


def save_threads_lines(lines: List[str]) -> None:
    path = ensure_threads_file_exists()
    with open(path, "w", encoding="utf-8") as f:
        f.writelines(lines)


def get_open_thread_indices(lines: List[str]) -> List[int]:
    """
    Returns a list of indices in `lines` that correspond to open threads.
    Open thread lines are those containing "- [ ]".
    """
    indices = []
    for i, line in enumerate(lines):
        if "- [ ]" in line:
            indices.append(i)
    return indices


def mark_open_thread_done(lines: List[str], open_index: int) -> Tuple[List[str], bool]:
    """
    open_index is the Nth open thread (0-based among open threads).
    Returns (new_lines, success_flag).
    """
    from datetime import datetime

    open_indices = get_open_thread_indices(lines)
    if open_index < 0 or open_index >= len(open_indices):
        return lines, False

    line_idx = open_indices[open_index]
    line = lines[line_idx]
    if "- [ ]" not in line:
        return lines, False

    # Find existing HTML comment (timestamp or metadata)
    import re
    now_iso = datetime.now().isoformat(timespec="seconds")
    m = re.search(r'<!--(.*?)-->', line)
    if m:
        meta = m.group(1).strip()
        # Check if already has created/cleared fields
        created = None
        cleared = None
        created_match = re.search(r'created:\s*([0-9T:\-]+)', meta)
        if created_match:
            created = created_match.group(1)
        else:
            # fallback: use whatever is in meta as created
            created = meta.split(",")[0].strip()
        # Compose new meta with both created and cleared
        new_meta = f"created: {created}, cleared: {now_iso}"
        # Replace the old meta with new meta
        new_line = re.sub(r'<!--.*?-->', f'<!-- {new_meta} -->', line)
    else:
        # No existing meta, just add cleared time
        new_line = line.rstrip('\n')
        new_line += f" <!-- cleared: {now_iso} -->\n"

    # Mark as done
    new_line = new_line.replace("- [ ]", "- [x]", 1)
    lines[line_idx] = new_line
    return lines, True

# --- New logic for parsing, sorting, and reordering threads ---

import re
from datetime import datetime

THREAD_LINE_RE = re.compile(r"^(- \[( |x)\] .*)<!-- (.*?) -->\s*$")

def parse_thread_line(line: str) -> Tuple[Optional[bool], Optional[datetime], str]:
    """
    Returns (is_open, sort_timestamp, line) for a thread line, or (None, None, line) if not a thread line.
    For closed threads, sort_timestamp is the cleared time if present, else None.
    For open threads, sort_timestamp is the created time if present, else None.
    """
    m = THREAD_LINE_RE.match(line.strip())
    if not m:
        return (None, None, line)
    is_open = "[ ]" in m.group(1)
    meta = m.group(3)
    created = None
    cleared = None
    import re
    from datetime import datetime
    created_match = re.search(r'created:\s*([0-9T:\-]+)', meta)
    if created_match:
        try:
            created = datetime.fromisoformat(created_match.group(1))
        except Exception:
            created = None
    cleared_match = re.search(r'cleared:\s*([0-9T:\-]+)', meta)
    if cleared_match:
        try:
            cleared = datetime.fromisoformat(cleared_match.group(1))
        except Exception:
            cleared = None
    # For closed threads, use cleared time for sorting; for open, use created
    if is_open:
        sort_ts = created
    else:
        sort_ts = cleared
    return (is_open, sort_ts, line)

def split_and_sort_threads(lines: List[str]) -> Tuple[list, list]:
    """
    Returns (open_thread_lines, closed_thread_lines), both sorted.
    Open threads: sorted by created time (most recent first).
    Closed threads: sorted by cleared time (most recent first), with those lacking cleared time at the bottom.
    Only thread lines are included; all section labels and non-thread lines are ignored.
    """
    open_threads = []
    closed_threads = []
    for line in lines:
        is_open, sort_ts, orig = parse_thread_line(line)
        if is_open is None:
            continue
        elif is_open:
            open_threads.append((sort_ts, orig))
        else:
            closed_threads.append((sort_ts, orig))
    # Open: sort by created (most recent first)
    open_threads.sort(key=lambda x: (x[0] or datetime.min), reverse=True)
    # Closed: sort by cleared (most recent first), with None at the bottom
    closed_threads.sort(key=lambda x: (x[0] is not None, x[0] or datetime.min), reverse=True)
    return [l for _, l in open_threads], [l for _, l in closed_threads]

def reorder_threads_file():
    """
    Reads the file, extracts all thread lines, sorts and groups them, and rewrites the file
    with a single 'Open:' and 'Closed:' section. All old section labels and non-thread lines are removed.
    """
    lines = load_threads_lines()
    open_threads, closed_threads = split_and_sort_threads(lines)
    new_lines = []

    new_lines.append("Open:\n")
    if open_threads:
        for line in open_threads:
            l = line if line.endswith('\n') else line+'\n'
            new_lines.append(l)
    else:
        new_lines.append("  (none)\n")
    new_lines.append("\n")

    new_lines.append("Closed:\n")
    if closed_threads:
        for line in closed_threads:
            l = line if line.endswith('\n') else line+'\n'
            new_lines.append(l)
    else:
        new_lines.append("  (none)\n")

    if not new_lines[-1].endswith('\n'):
        new_lines[-1] += '\n'

    save_threads_lines(new_lines)
