#!/usr/bin/env bash

set -euo pipefail

readonly CONFIG_DIR="${HOME}/.config/zee"
readonly SHORTCUTS_PATH="${CONFIG_DIR}/shortcuts.csv"
readonly DELIMITER=";"
readonly RESERVED_WORDS=("init" "add" "remove" "list")
readonly SUPPORTED_SHELLS=("fish" "zsh" "bash")

__path=

err() {
  echo -e "$@" >&2
  exit 1
}

main() {
  [[ $# -eq 0 ]] && help && exit 0

  create_config_if_not_exists

  case "$1" in
  -h | --help)
    help
    ;;
  init)
    init "${@:2}"
    ;;
  add)
    add "${@:2}"
    ;;
  remove)
    remove "${@:2}"
    ;;
  list)
    list
    ;;
  *)
    get_path "$@"
    if [[ -z "$__path" ]]; then
      err "Shortcut '${1}' doesn't exist."
    fi
    echo "$__path"
    ;;
  esac
}

help() {
  cat <<USAGE
Shell extension for defining shortcuts for quicker file system navigation.

Usage:
  $ z [command] ...

Options:
  -h, --help                Show this message

Commands:
  init <shell>              Generate shell configuration. Supported shells: fish, zsh, bash
  add <shortcut> <path>     Add shortcut
  remove <shortcut>         Remove shortcut
  list                      List all shortcuts
USAGE
}

init() {
  validate_num_of_params $# 1

  local shell="$1"
  local init_fn="init_${shell}"

  validate_shell_is_supported "$shell"

  $init_fn
}

add() {
  validate_num_of_params $# 2

  local shortcut="$1"
  local path="$2"

  validate_shortcut "$shortcut"
  validate_path "$path"

  path="$(cd "$path" && dirs +0)"

  echo "${shortcut};${path}" >>"$SHORTCUTS_PATH"
  echo "${shortcut}  →  ${path}"
}

remove() {
  validate_num_of_params $# 1

  local shortcut="$1"

  validate_shortcut_exists "$shortcut"

  sed -i '' "/^${shortcut};/d" "$SHORTCUTS_PATH"
  echo "Removed shortcut '${shortcut}'."
}

list() {
  awk -F"$DELIMITER" '{print $1, "→", $2}' "$SHORTCUTS_PATH" | sort | column -t
}

get_path() {
  validate_num_of_params $# 1

  local shortcut="$1"

  __path="$(awk -v shortcut="^${shortcut};" -F"$DELIMITER" '$0~shortcut {print $2}' "$SHORTCUTS_PATH")"
  __path="${__path/#\~/$HOME}"
}

create_config_if_not_exists() {
  if [[ ! -e "$SHORTCUTS_PATH" ]]; then
    mkdir -p "$CONFIG_DIR"
    touch "$SHORTCUTS_PATH"
  fi
}

validate_num_of_params() {
  local -i actual=$1
  local -i expected=$2

  if [[ $actual -ne $expected ]]; then
    err "${expected} arguments required, ${actual} provided."
  fi
}

validate_shortcut() {
  local shortcut="$1"

  validate_does_not_include_delimiter "$shortcut"
  validate_shortcut_is_not_a_reserved_word "$shortcut"
  validate_shortcut_not_exists "$shortcut"
}

validate_shortcut_exists() {
  local shortcut="$1"

  get_path "$shortcut"

  if [[ -z "$__path" ]]; then
    err "Shortcut '${shortcut}' doesn't exist."
  fi
}

validate_shortcut_not_exists() {
  local shortcut="$1"

  get_path "$shortcut"

  if [[ -n "$__path" ]]; then
    err "Shortcut '${shortcut}' already exists."
  fi
}

validate_path() {
  local path="$1"

  validate_does_not_include_delimiter "$path"
  validate_path_exists "$path"
}

validate_does_not_include_delimiter() {
  local value="$1"

  if [[ "$value" =~ $DELIMITER ]]; then
    err "'${DELIMITER}' is not an allowed character."
  fi
}

validate_shortcut_is_not_a_reserved_word() {
  local shortcut="$1"

  if [[ " ${RESERVED_WORDS[*]} " == *" $shortcut "* ]]; then
    err "Can't set shortcut for the reserved word '${shortcut}'."
  fi
}

validate_shell_is_supported() {
  local shell="$1"

  if ! [[ " ${SUPPORTED_SHELLS[*]} " == *" $shell "* ]]; then
    err "'${shell}' is not supported."
  fi
}

validate_path_exists() {
  local path="$1"

  if [[ ! -e "$path" ]]; then
    err "Path '${path}' doesn't exist."
  fi
}

init_fish() {
  cat <<'EOF'
function z
    switch "$argv[1]"
        case '-*' '--*' init add remove list
            zee $argv
        case ''
            zee
        case '*'
            set -l output (zee $argv)

            if test -n "$output"
                cd "$output"
            end
    end
end

# Add the following line to your config file (typically ~/.config/fish/config.fish):
# zee init fish | source
EOF
}

init_zsh() {
  cat <<'EOF'
function z {
  case "$1" in
  -* | --* | init | add | remove | list)
    zee "$@"
    ;;
  '')
    zee
    ;;
  *)
    local output
    output="$(zee "$@")"

    if [[ -n "$output" ]]; then
      cd "$output"
    fi
    ;;
  esac
}

# Add the following line to your config file (typically ~/.zshrc):
# eval "$(zee init zsh)"
EOF
}

init_bash() {
  cat <<'EOF'
function z {
  case "$1" in
  -* | --* | init | add | remove | list)
    zee "$@"
    ;;
  '')
    zee
    ;;
  *)
    local output
    output="$(zee "$@")"

    if [[ -n "$output" ]]; then
      cd "$output"
    fi
    ;;
  esac
}

# Add the following line to your config file (typically ~/.bashrc):
# eval "$(zee init bash)"
EOF
}

main "$@"
