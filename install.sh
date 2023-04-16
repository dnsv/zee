#!/usr/bin/env bash

set -euo pipefail

main() {
  local bin_dir="${HOME}/.local/bin"
  local bin_file="${bin_dir}/zee"

  echo "Installing Zee to '${bin_dir}'."

  mkdir -p "$bin_dir"
  curl -sSL https://raw.githubusercontent.com/dnsv/zee/main/zee.sh -o "$bin_file"
  chmod +x "$bin_file"

  case "$SHELL" in
  */bash*)
    # shellcheck disable=SC2016
    add_to_file 'eval "$(zee init bash)"' "${HOME}/.bashrc"
    ;;
  */zsh*)
    # shellcheck disable=SC2016
    add_to_file 'eval "$(zee init zsh)"' "${HOME}/.zshrc"
    ;;
  */fish*)
    add_to_file 'zee init fish | source' "${HOME}/.config/fish/config.fish"
    ;;
  *)
    echo "Unknown shell $(basename "$SHELL"). Supported shells are bash, fish & zsh."
    exit 1
    ;;
  esac

  echo "Done. Zee is now available through the command \`z\`."
  echo "Restart your shell for the changes to take effect."
}

add_to_file() {
  local text="$1"
  local file="$2"

  echo "Adding '${text}' to '${file}'."

  if ! grep -q "$text" "$file"; then
    echo "$text" >>"$file"
  else
    echo "'${text}' is already in '${file}'."
  fi
}

{ # This ensures the script doesn't run until it's fully downloaded.
  main
}
