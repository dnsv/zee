#!/usr/bin/env bash

set -euo pipefail

BIN_DIR="${HOME}/.local/bin"
# shellcheck disable=SC2088
BIN_DIR_TILDE="~/.local/bin"
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

  echo "Installed Zee to '${BIN_DIR}'"

  check_path
}

check_path() {
  if [[ ":${PATH}:" != *":${BIN_DIR}:"* ]]; then
    echo
    echo -e "${RED}Warning: '${BIN_DIR_TILDE}' is not in \$PATH. Zee won't work unless '${BIN_DIR_TILDE}' is added to \$PATH."
    echo -e "To fix this, add the following line to your shell configuration file:"
    echo
    echo -e "  For bash (~/.bashrc) or zsh (~/.zshrc):"
    echo -e "    export PATH=${BIN_DIR_TILDE}:\$PATH"
    echo
    echo -e "  For fish (~/.config/fish/config.fish):"
    echo -e "    fish_add_path ${BIN_DIR_TILDE}"
    echo
    echo -e "After adding, run 'source <your_shell_config_file>' or restart your terminal session.${RESET}"
  fi
}

{ # This ensures the script doesn't run until it's fully downloaded.
  main
}
