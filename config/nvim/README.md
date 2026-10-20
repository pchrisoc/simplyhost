# SimplyHost Neovim configuration

Saved from the local LazyVim configuration. Includes the navy, blue, cyan, and
teal theme, SimplyHost dashboard, completion bindings (Enter for newline,
Shift+Enter to accept when supported by the terminal), editor options, and
plugin version lockfile.

The Linux and Mac branches of `scripts/nvim.sh` install this directory in
`${XDG_CONFIG_HOME:-~/.config}/nvim`. The installer checks for an existing Neovim
executable before installing anything. Linux and Mac downloads support x86_64
and ARM64; macOS uses Homebrew when available. Archive installs use
`~/.local/bin/nvim`; include `~/.local/bin` in your shell PATH for future sessions.

If LazyVim is already configured, only `colorscheme.lua`, `completion.lua`,
`dashboard.lua`, and `simplyhost-options.lua` in `lua/plugins` are applied.
Changed files are moved to numbered `.bak` files; identical files are skipped.
Other configuration files, the existing plugin lockfile, data, state, and cache
are preserved. SimplyHost editor preferences are applied through a plugin spec
without replacing the existing `lua/config/options.lua`.

For a fresh install the entire saved config is copied. An existing non-LazyVim
config is backed up as a directory first. Downloads are staged and validated
before configuration backups or changes. LazyVim installs plugins on first launch.

These installation and update steps apply to the Linux and Mac branches. The
existing Windows branch has not been converted into a native PowerShell installer.

When run from this checkout, the installer uses this local directory. When piped
from a URL, it downloads this directory from the repository's `main` branch.
Commit and push this directory together with the installer before remote use.

Edit files here to change future installations. These files are a snapshot;
changes to a machine's `~/.config/nvim` are not automatically synchronized.
Swap files, logs, and inactive theme backups are not included.
