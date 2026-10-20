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

PS3="What OS? "

select choice in "Linux" "Mac" "Windows" "Quit"; do
  case "$choice" in
  "Linux")
    #NeoVim
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

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
    break
    ;;
  *)
    echo "Enter a valid number"
    ;;
  esac
done
