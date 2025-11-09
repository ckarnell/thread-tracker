#!/usr/bin/env bash
set -euo pipefail

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
  *":"${TARGET_BIN}":*)
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
