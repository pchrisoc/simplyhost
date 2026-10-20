#!/bin/bash
set -euo pipefail

logo() {
  printf '\033[2J\033[H'
  echo "   _____ _                 _       "
  echo "  / ____(_)               | |      "
  echo " | (___  _ _ __ ___  _ __ | |_   _ "
  echo "  \\___ \\| | '_ \` _ \\| '_ \\| | | | |"
  echo "  ____) | | | | | | | |_) | | |_| |"
  echo " |_____/|_|_| |_| |_| .__/|_|\\__, |"
  echo "    _    _          | |       __/ |"
  echo "   | |  | |         | |      |___/ "
  echo "   | |__| | ___  ___| |_           "
  echo "   |  __  |/ _ \\/ __| __|          "
  echo "   | |  | | (_) \\__ \\ |_           "
  echo "   |_|  |_|\\___/|___/\\__|          "
  echo "                                   "
  echo "                                   "
}

logo

# Usage: choice=$(choose "Title" "Option 1" "Option 2" ...)
choose() {
  if (($# < 2)); then
    printf 'Usage: choose "Title" "Option 1" ["Option 2" ...]\n' >&2
    return 2
  fi
  local title="$1"
  shift
  local options=("$@")
  local selected=0 index key sequence
  printf '%s (Up/Down, Enter)\n' "$title" >&2
  while :; do
    for index in "${!options[@]}"; do
      printf '\r\033[2K' >&2
      if [[ "$index" -eq "$selected" ]]; then
        printf '\033[7m > %s \033[0m\n' "${options[$index]}" >&2
      else
        printf '   %s\n' "${options[$index]}" >&2
      fi
    done
    IFS= read -r -s -n 1 key </dev/tty || return 1
    case "$key" in
    $'\033')
      sequence=''
      IFS= read -r -s -n 2 -t 1 sequence </dev/tty || true
      case "$sequence" in
      '[A' | 'OA') selected=$(((selected + ${#options[@]} - 1) % ${#options[@]})) ;;
      '[B' | 'OB') selected=$(((selected + 1) % ${#options[@]})) ;;
      esac
      ;;
    '')
      printf '%s\n' "${options[$selected]}"
      return 0
      ;;
    esac
    printf '\033[%sA' "${#options[@]}" >&2
  done
}

backup_path() {
  local original="$1" backup="${1}.bak" suffix=1
  while [[ -e "$backup" || -L "$backup" ]]; do
    backup="${original}.bak.${suffix}"
    suffix=$((suffix + 1))
  done
  mv -- "$original" "$backup"
  printf 'Backed up %s to %s\n' "$original" "$backup"
}

# Stage the saved SimplyHost config before moving any existing user files.
# A subshell keeps cleanup local to this function, including on failure.
install_lazyvim() (
  set -euo pipefail
  staging=$(mktemp -d)
  trap 'rm -rf -- "$staging"' EXIT
  script_path="${BASH_SOURCE[0]:-}"
  config_source=''
  if [[ -n "$script_path" && -f "$script_path" ]]; then
    config_source="$(dirname "$script_path")/../config/nvim"
  fi
  if [[ -n "$config_source" && -f "$config_source/init.lua" ]]; then
    cp -R "$config_source" "$staging/nvim"
  else
    curl -fsSL https://github.com/pchrisoc/simplyhost/archive/refs/heads/main.tar.gz \
      -o "$staging/source.tar.gz"
    tar -xzf "$staging/source.tar.gz" -C "$staging" simplyhost-main/config/nvim
    cp -R "$staging/simplyhost-main/config/nvim" "$staging/nvim"
  fi
  [[ -f "$staging/nvim/init.lua" && -f "$staging/nvim/lua/config/lazy.lua" ]]
  for plugin in colorscheme completion dashboard simplyhost-options; do
    if [[ ! -f "$staging/nvim/lua/plugins/$plugin.lua" ]]; then
      printf 'Downloaded config is missing %s.lua; existing config was not changed.\n' "$plugin" >&2
      exit 1
    fi
  done

  config_directory="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
  if [[ -f "$config_directory/lua/config/lazy.lua" ]] &&
    grep -q 'LazyVim/LazyVim' "$config_directory/lua/config/lazy.lua"; then
    printf 'Found LazyVim; updating SimplyHost settings and preserving other config files.\n'
    mkdir -p "$config_directory/lua/plugins"
    for plugin in colorscheme completion dashboard simplyhost-options; do
      destination="$config_directory/lua/plugins/$plugin.lua"
      if [[ -f "$destination" ]] && cmp -s "$staging/nvim/lua/plugins/$plugin.lua" "$destination"; then
        printf 'Already up to date: %s\n' "$plugin"
        continue
      fi
      if [[ -e "$destination" || -L "$destination" ]]; then
        backup_path "$destination"
      fi
      cp "$staging/nvim/lua/plugins/$plugin.lua" "$destination"
      printf 'Applied: %s\n' "$plugin"
    done
  else
    if [[ -e "$config_directory" || -L "$config_directory" ]]; then
      backup_path "$config_directory"
    fi
    mkdir -p "$(dirname "$config_directory")"
    cp -R "$staging/nvim" "$config_directory"
  fi
  printf 'Installed SimplyHost Neovim configuration.\n'
)

# Download into a temporary directory before replacing a managed installation.
install_neovim_archive() (
  set -euo pipefail
  local asset="$1" staging target
  staging=$(mktemp -d)
  trap 'rm -rf -- "$staging"' EXIT
  curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/${asset}.tar.gz" \
    -o "$staging/neovim.tar.gz"
  tar -xzf "$staging/neovim.tar.gz" -C "$staging"
  "$staging/$asset/bin/nvim" --version >/dev/null
  target="$HOME/.local/share/simplyhost/$asset"
  mkdir -p "$(dirname "$target")" "$HOME/.local/bin"
  if [[ -e "$target" || -L "$target" ]]; then backup_path "$target"; fi
  mv "$staging/$asset" "$target"
  ln -s "$target/bin/nvim" "$HOME/.local/bin/nvim"
)

persist_neovim_path() {
  local bin_directory="$1" login_shell="${2:-${SHELL:-/bin/bash}}"
  local path_line startup_file zsh_directory="${ZDOTDIR:-$HOME}"
  local startup_files=()
  case "$bin_directory" in
    /usr/bin|/bin) return 0 ;;
  esac
  # Quote paths containing spaces or shell metacharacters before saving them.
  printf -v path_line 'export PATH=%q:"$PATH"' "$bin_directory"
  case "${login_shell##*/}" in
    bash)
      startup_files=("$HOME/.bashrc" "$HOME/.profile")
      if [[ -f "$HOME/.bash_profile" ]]; then
        startup_files+=("$HOME/.bash_profile")
      elif [[ -f "$HOME/.bash_login" ]]; then
        startup_files+=("$HOME/.bash_login")
      fi
      ;;
    zsh) startup_files=("$zsh_directory/.zshrc" "$zsh_directory/.zprofile") ;;
    *)
      printf 'Add this to your shell startup configuration:\n%s\n' "$path_line"
      return 0
      ;;
  esac
  for startup_file in "${startup_files[@]}"; do
    mkdir -p "$(dirname "$startup_file")"
    if [[ ! -f "$startup_file" ]] || ! grep -Fqx -- "$path_line" "$startup_file"; then
      printf '\n# SimplyHost: Neovim command\n%s\n' "$path_line" >> "$startup_file"
      printf 'Saved Neovim PATH in %s\n' "$startup_file"
    fi
  done
  printf 'Open a new terminal to use nvim, or run this in your current shell:\n%s\n' "$path_line"
}

ensure_neovim() {
  local platform="$1" architecture candidate
  if command -v nvim >/dev/null 2>&1; then
    printf 'Neovim already installed: %s\n' "$(command -v nvim)"
    candidate=$(command -v nvim)
    if [[ "$candidate" == */* ]]; then persist_neovim_path "$(dirname "$candidate")"; fi
    return 0
  fi
  for candidate in "$HOME/.local/bin/nvim" /opt/nvim-linux-x86_64/bin/nvim /opt/nvim-linux-arm64/bin/nvim; do
    if [[ -x "$candidate" ]]; then
      export PATH="$(dirname "$candidate"):$PATH"
      printf 'Found existing Neovim: %s\n' "$candidate"
      persist_neovim_path "$(dirname "$candidate")"
      return 0
    fi
  done
  if [[ "$platform" == macos ]] && command -v brew >/dev/null 2>&1; then
    brew install neovim
  else
    case "$(uname -m)" in
      x86_64|amd64) architecture=x86_64 ;;
      arm64|aarch64) architecture=arm64 ;;
      *) printf 'Unsupported CPU architecture: %s\n' "$(uname -m)" >&2; return 1 ;;
    esac
    if [[ -e "$HOME/.local/bin/nvim" || -L "$HOME/.local/bin/nvim" ]]; then
      printf 'Cannot use existing ~/.local/bin/nvim; check this file before installing.\n' >&2
      return 1
    fi
    install_neovim_archive "nvim-${platform}-${architecture}"
    export PATH="$HOME/.local/bin:$PATH"
    printf 'Neovim installed in ~/.local/bin.\n'
  fi
  persist_neovim_path "$(dirname "$(command -v nvim)")"
}

choice=$(choose "What OS?" "Linux" "Mac" "Windows" "Quit")
case "$choice" in
"Linux")
  ensure_neovim linux

  install_lazyvim
  nvim </dev/tty
  ;;
"Mac")
  ensure_neovim macos

  install_lazyvim
  nvim </dev/tty
  ;;
"Windows")
  # NeoVim
  winget install Neovim.Neovim

  # LazyVim
  # required
  Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak
  # optional but recommended
  Move-Item $env:LOCALAPPDATA\nvim-data $env:LOCALAPPDATA\nvim-data.bak
  git clone https://github.com/LazyVim/starter $env:LOCALAPPDATA\nvim
  Remove-Item $env:LOCALAPPDATA\nvim\.git -Recurse -Force
  nvim
  ;;
"Quit")
  exit 0
  ;;
*)
  echo "Unknown OS selection"
  ;;
esac
