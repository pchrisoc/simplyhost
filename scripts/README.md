# SimplyHost scripts

Run a downloaded script with Bash, or use a local checkout:

```bash
bash scripts/menu.sh
bash scripts/doctor.sh
```

The scripts are self-contained and support the script site's `curl -fsSL URL | bash` commands. Prompts read from `/dev/tty`, so piping the script does not consume answers. Bash scripts support `--help`; the Windows script supports `-Help`. Interactive choices require a terminal; reports and the backup tools also accept arguments for unattended use.

## Available tools

| Script | Usage and behavior |
| --- | --- |
| `iterm2.sh` | Installs the captured macOS profile; `--apply-globals` applies appearance settings with iTerm2 closed. See Terminal setup below. |
| `powershell.ps1` | Adds the matching Windows Terminal profile, with optional PowerShell prompt and repeat command. Run with `-Help` for options. |
| `menu.sh` | Search names/descriptions and launch scripts with arrow keys. Uses siblings when available, otherwise downloads from `https://scripts.simplyhost.org`. |
| `doctor.sh [--strict]` | Read-only tools, hardware, capacity, network, and Docker checks. Strict mode exits 1 on findings. |
| `docker.sh` | Interactive official-repository Docker Engine/Compose installation for Debian/Ubuntu guests. Refuses Proxmox hosts and conflicting distro packages; verifies an existing installation. |
| `new-service.sh [DIRECTORY]` | Prompts for image, ports, data mount, and health endpoint. Creates a private project directory without overwriting existing files or launching containers. |
| `backup.sh SOURCE DESTINATION KEEP_COUNT` | Archives one directory, verifies readability, records SHA-256 metadata, and retains the requested count for that source. No arguments starts prompts. |
| `backup-check.sh DESTINATION [MAX_AGE_HOURS]` | Verifies all archives and checks newest backup age for each represented source (default 48 hours). Exits 1 on missing, corrupt, or stale backups. |
| `ports.sh [PORT ...]` | Linux TCP/UDP listeners; specified ports return exit 1 if occupied. |
| `storage.sh` | Filesystem, disks, mounts, and available ZFS/Proxmox storage reports. |
| `inventory.sh [OUTPUT.json]` | JSON hardware/network/Proxmox discovery. Missing tools produce null fields; failed available tools are recorded in `errors`. Refuses to overwrite an output file. |
| `health.sh` | Resource pressure, failed systemd services, and container health. Exits 1 on detected problems. Successful exited one-shot containers are allowed. |
| `logs.sh [container NAME \| service UNIT \| compose DIRECTORY] [--follow]` | Last 100 lines; no arguments opens a source menu. |
| `compose-update.sh [DIRECTORY]` | Saves resolved config and old-image rollback tags, pulls images, then separately confirms recreation with readiness checks. |

`nvim.sh` is the existing Neovim installer. `template.sh` is the starter template.

## Repeat commands

The Bash tools except the one-time Docker installer offer to add a function such as `sh-backup` or `sh-health` to `~/.bashrc`. This is opt-in and defaults to no. The script is copied to `~/.local/share/simplyhost/scripts/`; a piped invocation downloads a persistent copy. Repeating the installation does not duplicate the same function. Moving the repository afterward does not break the saved command.

Open a new Bash shell or run `source ~/.bashrc`, then pass ordinary script arguments:

```bash
sh-backup /srv/my-service /mnt/backups 7
sh-backup-check /mnt/backups 48
sh-ports 80 443
```

Shortcuts rerun the tool, prompting for missing arguments; they do not save answers or secrets. Set `SIMPLYHOST_NO_SHORTCUT=1` to suppress shortcut prompts. Noninteractive executions never change `.bashrc`. Run as the intended user: `sudo` may select root's home. These functions are for Bash; other shells need their own startup configuration.

## Requirements and operational limits

Bash 3.2+ and normal Unix tools are required. The installer, ports, and systemd features target Linux. Reports use available platform commands; unavailable optional sections are skipped. Inventory, backups, service creation, and updates require Python 3.8+. Docker tools require access to the Docker daemon; they do not silently escalate socket access or add users to the root-equivalent Docker group. The installer explicitly invokes sudo where necessary.

The Docker installation follows [Docker's Debian instructions](https://docs.docker.com/engine/install/debian/) and [Ubuntu instructions](https://docs.docker.com/engine/install/ubuntu/). It preserves conflicting packages and existing repository files for manual review. If a partial installation leaves repository configuration behind, inspect that configuration and finish with apt before retrying.

Backups are filesystem archives, not snapshots or database-aware backups. Stop writers or make native database dumps first. Symlinks are archived without following them. Destinations inside the source are rejected. Retention only prunes completed archives matching that source's path identifier after a new archive verifies. Keep the `.tar.gz.json` sidecars with their archives. Checksums detect corruption, not malicious modification. The age check can only assess sources represented in the directory; it is not a configured coverage inventory. No schedule is installed. Use a separate disk/off-site destination and an external scheduler if needed.

Restore into an empty directory and inspect the result before moving files into place:

```bash
mkdir /tmp/restore-check
tar -xzf /mnt/backups/simplyhost-backup-EXAMPLE.tar.gz -C /tmp/restore-check
# Original files are under /tmp/restore-check/data/
```

The service scaffold is for HTTP containers that include `wget`. Review image-specific paths, UID/GID ownership, health checks, environment variables, and backup needs before deploying. Published ports bind to localhost.

Compose updates support image-only projects with one healthy running container per service, without profiles. Run from the normal project environment (including any `COMPOSE_FILE` overrides). Config backups contain resolved secrets and are stored privately under `.simplyhost-updates/`; exclude this folder from version control. Application data is not backed up. On failure, the updater prints a saved `rollback.sh` command; review database migration compatibility before running it. Old image tags stay on the local daemon and must be retained until rollback is no longer needed. No automatic data rollback or image pruning occurs. Services without health checks only verify running state. An interrupted update may leave `.simplyhost-update.lock`; check for an active updater before removing it.

## Terminal setup

The embedded presets contain portable font, color and appearance settings. They exclude account paths, hostnames, credentials and arbitrary launch commands.

### macOS / iTerm2

From the repository:

```bash
bash scripts/iterm2.sh
```

Select **SimplyHost iTerm2** from iTerm2's Profiles menu. The installer uses [iTerm2 Dynamic Profiles](https://iterm2.com/documentation-dynamic-profiles.html). It creates `~/Library/Application Support/iTerm2/DynamicProfiles/simplyhost.json` and preserves the default profile selection. Existing managed files are backed up outside the DynamicProfiles directory.

To apply application-wide appearance settings, quit iTerm2 and run this from **Terminal.app**:

```bash
bash scripts/iterm2.sh --apply-globals
```

The script refuses to write global preferences while iTerm2 is running, because its cached preferences can overwrite them. It first saves the full target machine's current preferences privately in `~/.local/share/simplyhost/terminal-backups/`. Only the captured appearance keys are changed: scrollbar visibility, pane titles/dimming, borders, tab position/style/width/close buttons, and status-bar arrangement. Restart iTerm2 afterward. To restore a full preferences backup, quit iTerm2 and run `defaults import com.googlecode.iterm2 BACKUP.plist` from Terminal.app.

Install **JetBrainsMono Nerd Font Mono** separately if it is missing, using the [Nerd Fonts download page](https://www.nerdfonts.com/font-downloads). The profile's internal macOS font name is `JetBrainsMonoNFM-Regular`. Font binaries are not bundled.

The installer offers an optional `sh-iterm2` repeat command in `~/.bashrc`. If you use the Zsh profile, run the installer directly or define the equivalent function in `.zshrc`; `.bashrc` is only read by Bash.

### Windows Terminal / PowerShell

Appearance belongs to Windows Terminal, while the command prompt belongs to PowerShell. This installer handles both. Download the `.ps1` file, inspect it, and run it in PowerShell:

```powershell
Invoke-WebRequest -Uri https://scripts.simplyhost.org/powershell.ps1 -OutFile powershell.ps1
.\powershell.ps1
```

Or from a local checkout:

```powershell
.\scripts\powershell.ps1
```

The script uses [Windows Terminal JSON fragments](https://learn.microsoft.com/en-us/windows/terminal/json-fragment-extensions) to add **SimplyHost PowerShell**, without rewriting `settings.json` or changing your default profile. It prefers PowerShell 7 (`pwsh.exe`) when present and otherwise uses Windows PowerShell (`powershell.exe`). PowerShell 5.1+ and Windows Terminal are prerequisites; this script does not install them or change execution policy. If execution is blocked, review your system's policy rather than bypassing it automatically.

The fragment lives at `%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\SimplyHost\terminal.json`. Install the same Nerd Font on Windows, then restart Terminal and choose the new profile. User settings with higher precedence can override fragment values. The two palettes automatically follow Terminal's application theme.

Optional prompts offer:

- A PowerShell prompt with the current directory, Git branch or detached revision, command failure status, and running background-job count. Git is optional. This approximates the visible Powerlevel10k segments using native PowerShell; it does not install Zsh, Powerlevel10k, or Starship. Existing prompt initialization remains in your profile, but this appended function takes precedence when the profile loads.
- A `sh-terminal` command for rerunning the saved installer. The persistent script lives under `%LOCALAPPDATA%\SimplyHost\scripts\`.

Both options update marked blocks in `$PROFILE.CurrentUserAllHosts`, preserving unrelated content and making backups before changes. Start a new PowerShell session or run `. $PROFILE.CurrentUserAllHosts` to activate them. Windows PowerShell and PowerShell 7 have separate profile locations, so configure each version separately if you use both.

For explicit options or unattended installation:

```powershell
.\powershell.ps1 -InstallPrompt -AddCommand -NoPrompt
.\powershell.ps1 -WhatIf
```

The Windows equivalent maps the font, ligatures, bold/bright text, scrollback, opacity, scrollbar, and both color palettes. iTerm2's pane dimming, status bars, tab styling, shell integration, and window dimensions do not all have profile-fragment equivalents. Display P3 color channels are rounded to 8-bit RGB, so colors can vary slightly. The PowerShell prompt puts status inline rather than reproducing Zsh's right prompt.

Remove the SimplyHost fragment to remove its Windows Terminal profile and schemes. Remove the SimplyHost marked blocks from your PowerShell profile to restore the previous prompt/commands; backups are in `%LOCALAPPDATA%\SimplyHost\terminal-backups\`.

## Maintenance

Edit the standalone scripts directly. The index discovers executable files and common script extensions anywhere under `scripts/` from GitHub when the page loads. Push additions, renames, or deletions to `main`; no index generation command is needed. Use Refresh on the page to reload the list. GitHub API availability and unauthenticated rate limits apply.

Cloudflare Pages can use `scripts` as the root directory, an empty build command, and `.` as the output directory. For existing projects that still run `node tools/build-script-index.mjs`, a small compatibility entry point verifies the index is present. It does not regenerate files. Internal deployment helpers under `tools/` are excluded from the public script list.

Keep inventory exports, local terminal exports, shell profiles, credentials, and backup archives outside the repository. Ignore rules cover common names, but review any files before committing.
