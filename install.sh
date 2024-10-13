#!/usr/bin/env bash

set -euo pipefail

BIN_DIR="${HOME}/.local/bin"
BIN_FILE="${BIN_DIR}/zee"

RESET=$(tput sgr0)
# shellcheck disable=SC2034
readonly RESET
RED=$(tput setaf 1)
# shellcheck disable=SC2034
readonly RED

main() {
  echo "Installing Zee to '${BIN_DIR}'."

  mkdir -p "$BIN_DIR"
  curl -sSL https://raw.githubusercontent.com/dnsv/zee/main/zee.sh -o "$BIN_FILE"
  chmod +x "$BIN_FILE"

  case "$SHELL" in
  */bash*)
    # shellcheck disable=SC2016
    add_to_file 'export PATH="$HOME/.local/bin:$PATH"' "${HOME}/.bashrc"
    # shellcheck disable=SC2016
    add_to_file 'eval "$(zee init bash)"' "${HOME}/.bashrc"
    ;;
  */zsh*)
    # shellcheck disable=SC2016
    add_to_file 'export PATH="$HOME/.local/bin:$PATH"' "${HOME}/.zshrc"
    # shellcheck disable=SC2016
    add_to_file 'eval "$(zee init zsh)"' "${HOME}/.zshrc"
    ;;
  */fish*)
    add_to_file 'fish_add_path ~/.local/bin' "${HOME}/.config/fish/config.fish"
    add_to_file 'zee init fish | source' "${HOME}/.config/fish/config.fish"
    ;;
  *)
    echo "Unknown shell $(basename "$SHELL"). Supported shells are bash, fish & zsh."
    exit 1
    ;;
  esac

  echo "Installation complete. Zee will be available through the command \`z\`" \
    "after sourcing your shell configuration file or restarting your terminal."
}

add_to_file() {
  local text="$1"
  local file="$2"

  if ! grep -q "$text" "$file"; then
    echo "Adding '${text}' to '${file}'."
    echo "$text" >>"$file"
  fi
}

{ # This ensures the script doesn't run until it's fully downloaded.
  main
}
