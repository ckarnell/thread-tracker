#!/usr/bin/env bash

# ------------------------------------------------------------
# Safe mode for both bash and zsh
# ------------------------------------------------------------
# We can't use "set -e" because sourcing + "exit" kills the shell.
# Instead, we manually handle failures.

safe_exit() {
  # Works even when sourced: use return if possible, else exit.
  return 1 2>/dev/null || exit 1
}

# Detect whether the script is being sourced
is_sourced() {
  # bash
  if [ -n "${BASH_SOURCE-}" ]; then
    [ "${BASH_SOURCE[0]}" != "${0}" ]
  # zsh
  elif [ -n "${ZSH_EVAL_CONTEXT-}" ]; then
    [[ $ZSH_EVAL_CONTEXT == *:file ]]
  else
    false
  fi
}

if ! is_sourced; then
  echo "⚠️  This script must be sourced, not executed."
  echo "   Run:  source ./install.sh"
  safe_exit
fi

# ------------------------------------------------------------
# THREADS_FILE setup
# ------------------------------------------------------------
if [ -n "${THREADS_FILE-}" ]; then
  echo "THREADS_FILE is already set to '$THREADS_FILE'. Skipping setup."
else
  DEFAULT_PATH="$HOME/Documents/Obsidian Vault/Threads/threads.md"
  read -r "?THREADS_FILE is not set. Do you want to set it to '$DEFAULT_PATH'? [y/N] " RESP
  if [[ "$RESP" =~ ^[Yy]$ ]]; then
    VAULT_DIR="$HOME/Documents/Obsidian Vault"
    THREADS_DIR="$VAULT_DIR/Threads"

    if [ ! -d "$VAULT_DIR" ]; then
      echo "Error: Directory '$VAULT_DIR' does not exist. Please create it and rerun."
      safe_exit
    fi

    mkdir -p "$THREADS_DIR"
    [ -f "$DEFAULT_PATH" ] || { touch "$DEFAULT_PATH" && echo "Created file '$DEFAULT_PATH'."; }

    export THREADS_FILE="$DEFAULT_PATH"
    echo "THREADS_FILE set to '$THREADS_FILE' for this session."

    # Persist if not already present
    if ! grep -q 'export THREADS_FILE=' "$HOME/.zshrc"; then
      echo "export THREADS_FILE=\"$DEFAULT_PATH\"" >> "$HOME/.zshrc"
      echo "Added THREADS_FILE to ~/.zshrc"
    fi
  else
    echo "THREADS_FILE will not be set."
  fi
fi

# ------------------------------------------------------------
# Repo setup
# ------------------------------------------------------------
# zsh vs bash portable path resolution
if [ -n "${ZSH_VERSION-}" ]; then
  REPO_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
else
  REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

BIN_DIR="$REPO_DIR/bin"
TARGET_BIN="$HOME/.local/bin"

echo "Repo directory: $REPO_DIR"
echo "Source bin dir: $BIN_DIR"
echo "Target bin dir: $TARGET_BIN"

mkdir -p "$TARGET_BIN"

chmod +x "${BIN_DIR}/tt-add" "${BIN_DIR}/tt-list" "${BIN_DIR}/tt-done"

for f in tt-add tt-list tt-done; do
  src="$BIN_DIR/$f"
  dest="$TARGET_BIN/$f"
  if [ -L "$dest" ] || [ -f "$dest" ]; then
    echo "Updating existing $dest"
    rm -f "$dest"
  fi
  ln -s "$src" "$dest"
  echo "Linked $src -> $dest"
done

# PATH check
case ":$PATH:" in
  *:"$TARGET_BIN":*)
    echo "✅ $TARGET_BIN is already in PATH."
    ;;
  *)
    echo "⚠️  $TARGET_BIN is not in your PATH."
    echo "   Add this line to your ~/.zshrc:"
    echo "     export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac

echo
echo "✅ Setup complete."
echo "THREADS_FILE is currently: $THREADS_FILE"
echo
echo "Try:"
echo "  tt-add     # capture a thread"
echo "  tt-list    # list open threads"
echo "  tt-done 1  # mark the first open thread done"

