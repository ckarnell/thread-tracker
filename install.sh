#!/usr/bin/env bash

# Safe exit helper (won't close terminal)
safe_exit() {
  return 1 2>/dev/null || exit 1
}

# Detect if script is sourced (works in bash and zsh)
is_sourced() {
  # zsh
  if [ -n "${ZSH_EVAL_CONTEXT-}" ]; then
    [[ $ZSH_EVAL_CONTEXT == *:file ]]
  # bash
  elif [ -n "${BASH_SOURCE-}" ]; then
    [ "${BASH_SOURCE[0]}" != "${0}" ]
  else
    false
  fi
}

# Only warn if actually executed, not sourced
if ! is_sourced; then
  echo "⚠️  This script must be sourced, not executed."
  echo "   Run:  source ./install.sh"
  safe_exit
fi

# -------------------------------------------------------------------
# THREADS_FILE setup
# -------------------------------------------------------------------
if [ -n "${THREADS_FILE-}" ]; then
  echo "THREADS_FILE is already set to '$THREADS_FILE'."
else
  DEFAULT_PATH="$HOME/Documents/Obsidian Vault/Threads/threads.md"
  read -r "?THREADS_FILE is not set. Set it to '$DEFAULT_PATH'? [y/N] " RESP
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
  else
    echo "THREADS_FILE will not be set."
  fi
fi

# -------------------------------------------------------------------
# Ask to add THREADS_FILE to ~/.zshrc
# -------------------------------------------------------------------
if [ -n "${THREADS_FILE-}" ]; then
  if grep -q 'export THREADS_FILE=' "$HOME/.zshrc"; then
    echo "THREADS_FILE already found in ~/.zshrc. Skipping."
  else
    read -r "?Would you like to permanently add THREADS_FILE to ~/.zshrc? [y/N] " RESP_ADD
    if [[ "$RESP_ADD" =~ ^[Yy]$ ]]; then
      echo "export THREADS_FILE=\"$THREADS_FILE\"" >> "$HOME/.zshrc"
      echo "Added THREADS_FILE to ~/.zshrc"
    else
      echo "Skipping addition to ~/.zshrc."
    fi
  fi
fi

# -------------------------------------------------------------------
# Repo setup
# -------------------------------------------------------------------
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
chmod +x "${BIN_DIR}/tt-add" "${BIN_DIR}/tt-list" "${BIN_DIR}/tt-done" "${BIN_DIR}/tt-combo"

# -------------------------------------------------------------------
# Check for existing implementations elsewhere in PATH and uninstall if found
# -------------------------------------------------------------------
for f in tt-add tt-list tt-done tt-combo; do
  # Find all locations in PATH
  existing_path="$(command -v "$f" 2>/dev/null || true)"
  if [ -n "$existing_path" ] && [ "$existing_path" != "$TARGET_BIN/$f" ]; then
    echo "⚠️  Found existing '$f' at: $existing_path"
    read -r "?Do you want to remove $existing_path? (may require sudo) [y/N] " RESP_RM
    if [[ "$RESP_RM" =~ ^[Yy]$ ]]; then
      if rm -f "$existing_path" 2>/dev/null; then
        echo "Removed $existing_path"
      else
        echo "Could not remove $existing_path without sudo. Trying with sudo..."
        if sudo rm -f "$existing_path"; then
          echo "Removed $existing_path with sudo"
        else
          echo "Failed to remove $existing_path. Please remove it manually."
        fi
      fi
    else
      echo "Skipping removal of $existing_path."
    fi
  fi

  src="$BIN_DIR/$f"
  dest="$TARGET_BIN/$f"
  if [ -L "$dest" ] || [ -f "$dest" ]; then
    echo "Updating existing $dest"
    rm -f "$dest"
  fi
  ln -s "$src" "$dest"
  echo "Linked $src -> $dest"
done

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
echo "  tt-combo   # add or complete a thread in one step"
