# SimplyHost Neovim configuration

Saved from the local LazyVim configuration. Includes the navy, blue, cyan, and
teal theme, SimplyHost dashboard, completion bindings (Enter for newline,
Shift+Enter to accept when supported by the terminal), editor options, and
plugin version lockfile.

`scripts/nvim.sh` automatically detects Linux (including WSL) or macOS and installs this directory in
`${XDG_CONFIG_HOME:-~/.config}/nvim`. The installer checks for an existing Neovim
executable before installing anything. Linux and Mac downloads support x86_64
and ARM64; macOS uses Homebrew when available. Archive installs use
`~/.local/bin/nvim`. The installer saves the Neovim executable directory in Bash
or Zsh startup files, including when repairing an existing installation outside
PATH. Repeated runs do not duplicate the same export. If Neovim is unavailable on
the invoking shell's original PATH, the installer also creates
`/usr/local/bin/nvim` as a link to the executable, requesting sudo when necessary.
This makes the command available immediately after a piped installation, without
restarting the shell. The installer verifies `/usr/local/bin` is on that original
PATH and refuses to overwrite an existing file or link.

If LazyVim is already configured, only `colorscheme.lua`, `completion.lua`,
`dashboard.lua`, and `simplyhost-options.lua` in `lua/plugins` are applied.
Changed files are moved to numbered `.bak` files; identical files are skipped.
Other configuration files, the existing plugin lockfile, data, state, and cache
are preserved. SimplyHost editor preferences are applied through a plugin spec
without replacing the existing `lua/config/options.lua`.

For a fresh install the entire saved config is copied. An existing non-LazyVim
config is backed up as a directory first. Downloads are staged and validated
before configuration backups or changes. LazyVim installs plugins on first launch.

Native Windows shells are detected and exit with a message to use WSL; this Bash
installer does not execute PowerShell commands.

When run from this checkout, the installer uses this local directory. When piped
from a URL, it downloads this directory from the repository's `main` branch.
Commit and push this directory together with the installer before remote use.

Edit files here to change future installations. These files are a snapshot;
changes to a machine's `~/.config/nvim` are not automatically synchronized.
Swap files, logs, and inactive theme backups are not included.
