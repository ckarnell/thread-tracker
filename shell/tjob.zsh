# Source this from your ~/.zshrc, e.g.:
#   source /path/to/threads-tracker/shell/tjob.zsh

tjob() {
  if [ $# -eq 0 ]; then
    echo "Usage: tjob <command...>"
    return 1
  fi

  local CMD="$*"
  local CWD="$PWD"

  # Log a thread
  tt-add <<EOF >/dev/null 2>&1
EOF

  echo "Running long job: $CMD"
  eval "$CMD"
}
