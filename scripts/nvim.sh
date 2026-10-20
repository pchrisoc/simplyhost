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

choice=$(choose "What OS?" "Linux" "Mac" "Windows" "Quit")
case "$choice" in
"Linux")
  #NeoVim
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

  #LazyVim
  # Back up existing configuration and data without overwriting earlier backups.
  for directory in "$HOME/.config/nvim" "$HOME/.local/share/nvim" \
    "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
    if [[ -e "$directory" || -L "$directory" ]]; then
      backup="${directory}.bak"
      suffix=1
      while [[ -e "$backup" || -L "$backup" ]]; do
        backup="${directory}.bak.${suffix}"
        suffix=$((suffix + 1))
      done
      mv -- "$directory" "$backup"
      printf 'Backed up %s to %s\n' "$directory" "$backup"
    fi
  done
  mkdir -p "$HOME/.config"
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"
  nvim </dev/tty
  ;;
"Mac")
  #NeoWim
  if command -v brew >/dev/null 2>&1; then
    brew install neovim
  else
    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-x86_64.tar.gz
    tar xzf nvim-macos-x86_64.tar.gz
    ./nvim-macos-x86_64/bin/nvim
  fi

  #LazyVim
  # required
  mv ~/.config/nvim{,.bak}
  # optional but recommended
  mv ~/.local/share/nvim{,.bak}
  mv ~/.local/state/nvim{,.bak}
  mv ~/.cache/nvim{,.bak}
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git
  nvim
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
