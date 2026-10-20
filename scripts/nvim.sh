#!/bin/bash
set -euo pipefail

# Keep the invoking shell's PATH before this installer adds private directories.
original_path="$PATH"

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

detect_os() {
  case "$(uname -s)" in
    Linux) printf 'linux\n' ;;
    Darwin) printf 'macos\n' ;;
    MINGW*|MSYS*|CYGWIN*)
      printf 'Native Windows is not supported by this Bash installer. Run it inside WSL instead.\n' >&2
      return 1
      ;;
    *)
      printf 'Unsupported operating system: %s\n' "$(uname -s)" >&2
      return 1
      ;;
  esac
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
}

expose_neovim_command() {
  local executable="$1" parent_path="$2" link=/usr/local/bin/nvim
  # If the original PATH already resolves nvim, no global link is necessary.
  if (export PATH="$parent_path"; command -v nvim >/dev/null 2>&1); then
    return 0
  fi
  case ":$parent_path:" in
    *:/usr/local/bin:*) ;;
    *)
      printf '/usr/local/bin is not on your current PATH; cannot expose nvim to this shell automatically.\n' >&2
      return 1
      ;;
  esac
  if [[ -e "$link" || -L "$link" ]]; then
    printf 'Cannot create %s: a file already exists there. It was not replaced.\n' "$link" >&2
    return 1
  fi
  if [[ -d /usr/local/bin && -w /usr/local/bin ]]; then
    ln -s "$executable" "$link"
  else
    if ! command -v sudo >/dev/null 2>&1; then
      printf 'sudo is required to create %s.\n' "$link" >&2
      return 1
    fi
    printf 'Creating %s so nvim works in your current shell.\n' "$link"
    sudo -v </dev/tty
    sudo mkdir -p /usr/local/bin
    sudo ln -s "$executable" "$link"
  fi
  if ! (export PATH="$parent_path"; command -v nvim >/dev/null 2>&1); then
    printf 'Neovim is still unavailable on the original PATH.\n' >&2
    return 1
  fi
  printf 'nvim is now available from your current shell.\n'
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

platform=$(detect_os)
printf 'Detected OS: %s · CPU: %s\n' "$platform" "$(uname -m)"
ensure_neovim "$platform"
expose_neovim_command "$(command -v nvim)" "$original_path"
install_lazyvim
nvim </dev/tty
