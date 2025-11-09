#!/usr/bin/env bash
set -euo pipefail

# THREADS_FILE setup logic
if [ -n "${THREADS_FILE-}" ]; then
  echo "THREADS_FILE is already set to '$THREADS_FILE'. Skipping setup."
else
  THREADS_FILE="$HOME/Documents/Obsidian Vault/Threads/threads.md"
  read -p "THREADS_FILE is not set. Do you want to set it to '$THREADS_FILE'? [y/N] " RESP
  if [[ "$RESP" =~ ^[Yy]$ ]]; then
    if [ ! -d "$HOME/Documents/Obsidian Vault" ]; then
      echo "Error: Directory '$HOME/Documents/Obsidian Vault' does not exist. Please create it and rerun the script."
      exit 1
    fi
    if [ ! -d "$HOME/Documents/Obsidian Vault/Threads" ]; then
      mkdir -p "$HOME/Documents/Obsidian Vault/Threads"
      echo "Created directory '$HOME/Documents/Obsidian Vault/Threads'."
    fi
    if [ ! -f "$THREADS_FILE" ]; then
      touch "$THREADS_FILE"
      echo "Created file '$THREADS_FILE'."
    fi
    echo "export THREADS_FILE=\"$THREADS_FILE\"" >> "$HOME/.zshrc"
    echo "THREADS_FILE set and added to ~/.zshrc."
  else
    echo "THREADS_FILE will not be set."
  fi
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$REPO_DIR/bin"
TARGET_BIN="${HOME}/.local/bin"

echo "Repo directory: ${REPO_DIR}"
echo "Source bin dir: ${BIN_DIR}"
echo "Target bin dir: ${TARGET_BIN}"

mkdir -p "${TARGET_BIN}"

# Make sure scripts are executable
chmod +x "${BIN_DIR}/tt-add" "${BIN_DIR}/tt-list" "${BIN_DIR}/tt-done"

for f in tt-add tt-list tt-done; do
  src="${BIN_DIR}/${f}"
  dest="${TARGET_BIN}/${f}"
  if [ -L "${dest}" ] || [ -f "${dest}" ]; then
    echo "Updating existing ${dest}"
    rm -f "${dest}"
  fi
  ln -s "${src}" "${dest}"
  echo "Linked ${src} -> ${dest}"
done

# Suggest PATH update if needed
case ":$PATH:" in
  *:"${TARGET_BIN}":*)
    echo "✅ ${TARGET_BIN} is already in PATH."
    ;;
  *)
    echo "⚠️  ${TARGET_BIN} is not in your PATH."
    echo "   Add this line to your shell config (e.g. ~/.zshrc):"
    echo "     export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac

echo
echo "Done. Try:"
echo "  tt-add   # capture a thread"
echo "  tt-list  # list open threads"
echo "  tt-done 1  # mark the first open thread done"

