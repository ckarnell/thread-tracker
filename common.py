import os
from pathlib import Path
from typing import List, Tuple

DEFAULT_THREADS_FILE = os.path.expanduser("~/threads.md")
CONFIG_FILE = os.path.expanduser("~/.threadstrc")


def parse_config_file() -> str | None:
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
            f.write("# Open Threads\n\n")
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
    open_indices = get_open_thread_indices(lines)
    if open_index < 0 or open_index >= len(open_indices):
        return lines, False

    line_idx = open_indices[open_index]
    line = lines[line_idx]
    if "- [ ]" not in line:
        return lines, False

    lines[line_idx] = line.replace("- [ ]", "- [x]", 1)
    return lines, True
