# SimplyHost scripts

Run a downloaded script with Bash, or use a local checkout:

```bash
bash scripts/menu.sh
bash scripts/doctor.sh
```

The scripts are self-contained and support the script site's `curl -fsSL URL | bash` commands. Prompts read from `/dev/tty`, so piping the script does not consume answers. Bash scripts support `--help`; Windows scripts support `-Help`. Interactive choices require a terminal; reports and the backup tools also accept arguments for unattended use.

## Choose your platform

At [scripts.simplyhost.org](https://scripts.simplyhost.org), use the logo buttons to the right of the title to select **Windows (PowerShell)** or **macOS / Linux (Bash)**. The selected button is highlighted; hover or focus it for the platform label. The site remembers your preference, filters unsupported tools, and generates commands using the script domain. Windows downloads go into the temporary directory and run through PowerShell; they do not require WSL or PowerShell's `curl` alias. Switching platforms immediately updates selected commands. The list still discovers new scripts automatically from GitHub; new `.ps1`/`.bat`/`.cmd` files are Windows-only by default and shell scripts are Unix-only until a native Windows implementation is registered.

| Tools | Windows | macOS / Linux |
| --- | --- | --- |
| Neovim | `nvim.ps1`: native Neovim + Git and SimplyHost LazyVim config | `nvim.sh` |
| Menu, doctor, health, ports, storage, inventory | `windows.ps1 -Tool NAME`, using native Windows commands | Corresponding `.sh`; ports supports `lsof` on macOS and `ss` on Linux |
| Backup, backup-check | `windows.ps1 -Tool NAME`; requires Python 3.8+ | Corresponding `.sh`; requires Python 3.8+ |
| New-service, logs, compose-update | `windows.ps1 -Tool NAME`; Docker operations need an existing daemon/Compose v2 | Corresponding `.sh`; Docker operations need an existing daemon/Compose v2 |
| Terminal setup | `powershell.ps1` | `iterm2.sh` on macOS only |
| Docker Engine installation | Hidden; install Docker Desktop separately | `docker.sh` on Debian/Ubuntu only |
| Starter template | `windows.ps1 -Tool template` | `template.sh` |

Windows service logs read Service Control Manager events; systemd logs are Linux-only. `-Follow` applies to Docker logs. The Windows updater preserves resolved configuration and old-image tags, asks separately before pulling and recreating, and writes `rollback.ps1` with the same image/data-migration limitations as the Bash updater. Its snapshots are restricted to the current user.

The native Windows helpers are self-contained downloads. Examples after downloading `windows.ps1`:

```powershell
.\windows.ps1 -Tool backup -Source C:\Projects -Destination D:\Backups -Keep 7
.\windows.ps1 -Tool backup-check -Destination D:\Backups -MaxAgeHours 48
.\windows.ps1 -Tool ports -Port 80,443
.\windows.ps1 -Tool compose-update -Directory C:\Projects\my-service
```

Each recurring Windows tool offers to save a `sh-NAME` command in `$PROFILE.CurrentUserAllHosts`, backed by a persistent copy in `%LOCALAPPDATA%\SimplyHost\scripts`. Use `-AddCommand` to request it or `-NoPrompt` to skip optional questions. Profile edits preserve existing content and keep a backup. Arguments use PowerShell's named form, e.g. `sh-backup -Source C:\Projects -Destination D:\Backups`.

## Available tools

| Script | Usage and behavior |
| --- | --- |
| `iterm2.sh` | Installs the captured macOS profile; `--apply-globals` applies appearance settings with iTerm2 closed. See Terminal setup below. |
| `powershell.ps1` | Installs a Solarized Dark Windows Terminal profile, Powerlevel10k-style prompt and Nerd Font; makes the themed profile the default. Run with `-Help` for options. |
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

`nvim.sh` and `nvim.ps1` install the same SimplyHost Neovim configuration on their respective systems. `template.sh` is the starter template.

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

Bash 3.2+ and normal Unix tools are required. The Docker Engine installer and systemd features target Linux; ports supports macOS and Linux. Reports use available platform commands; unavailable optional sections are skipped. Inventory, backups, service creation, and updates require Python 3.8+. Docker tools require access to the Docker daemon; they do not silently escalate socket access or add users to the root-equivalent Docker group. The installer explicitly invokes sudo where necessary.

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

Install **JetBrainsMono NFM** separately if it is missing, using the [Nerd Fonts download page](https://www.nerdfonts.com/font-downloads). The profile's internal macOS font name is `JetBrainsMonoNFM-Regular`. Font binaries are not bundled.

The installer offers an optional `sh-iterm2` repeat command in `~/.bashrc`. If you use the Zsh profile, run the installer directly or define the equivalent function in `.zshrc`; `.bashrc` is only read by Bash.

### Windows PowerShell / Windows Terminal

The installer uses **Solarized Dark** and an [Oh My Posh](https://ohmyposh.dev/docs/installation/windows) theme based on the captured Powerlevel10k layout: one prompt line with an OS icon, directory and Git segments, with command duration and failure status on the same line. No right-edge cursor positioning is used. Commands are entered immediately after the path/Git segments; there is no extra green arrow marker. It replaces the earlier basic SimplyHost prompt. The terminal background stays `#002B36` in both light and dark Windows modes.

Run from a local checkout, or download into your temporary directory:

```powershell
$installer = Join-Path $env:TEMP 'simplyhost-terminal.ps1'
Invoke-WebRequest -Uri https://scripts.simplyhost.org/powershell.ps1 -OutFile $installer
& $installer -AddCommand -NoPrompt
```

The installer:

- Adds **SimplyHost PowerShell** using a Windows Terminal fragment, with JetBrainsMono NFM at 15 pt and the standard Solarized Dark palette.
- Installs Oh My Posh through `winget` when missing, then installs the required Nerd Font through Oh My Posh if not already present. These downloads use the official package and font sources.
- Saves the powerline theme under `%LOCALAPPDATA%\SimplyHost\themes\solarized-dark.omp.json` and replaces the marked SimplyHost prompt block in `$PROFILE.CurrentUserAllHosts` with Oh My Posh initialization.
- Makes the themed profile the default in existing stable, preview, or unpackaged Windows Terminal settings. It writes the actual Windows font family `JetBrainsMono NFM` and Solarized background/text colors explicitly on the SimplyHost profile. It also themes the built-in Windows PowerShell profile, existing PowerShell executable profiles, and `profiles.defaults`, which Terminal uses when a Start-menu hand-off has no matching profile. Shared defaults affect other shells that inherit appearance; explicit appearance on unrelated shell profiles is preserved. Focused and unfocused colors are both Solarized Dark. When `WT_PROFILE_ID` identifies the active tab, its profile gets the same appearance while its shell/name and unrelated settings are preserved. Comments, trailing commas, and unrelated settings are preserved. Backups are stored outside the Terminal configuration folders.
- Saves a console appearance helper under `%LOCALAPPDATA%\SimplyHost\console.ps1` and loads it from your PowerShell profile on every startup. The built-in **Windows PowerShell** Start-menu entry gets JetBrainsMono NFM, Solarized colors, and the same prompt. Existing console text and scrollback are preserved. Windows Terminal uses its own saved font settings instead, including when it hosts a Start-menu launch without setting `WT_SESSION`. The helper only changes font, palette, and console color attributes when the window class is `ConsoleWindowClass`. It leaves Terminal pseudoconsole sessions alone even if they have a visible window flag or omit the Terminal environment markers.
- Also saves an optional **SimplyHost PowerShell** Start-menu entry for Windows Terminal when Terminal is available.
- Optionally adds `sh-terminal` for repeat use. `-AddCommand` enables it explicitly; otherwise an interactive prompt offers it.

The installer opens a fresh PowerShell window. Afterwards, open **Windows PowerShell** normally from Start; the appearance is reapplied automatically by its profile. A `-NoProfile` launch deliberately skips these settings. If the console cannot find the newly installed font, it reports a warning: restart Windows once so Console Host can discover it, then reopen PowerShell. Windows Terminal users can also select the themed profile with `wt -p "SimplyHost PowerShell"`.

The new Terminal profile uses the same PowerShell version that ran the installer. Prompt initialization uses UTF-8 evaluation and unloads the previous Oh My Posh module when re-sourced, so cached scripts and old prompt line counts are replaced. Windows PowerShell and PowerShell 7 use separate shell profiles; rerun in each version if you use both. Git is optional and its segment appears only inside a repository. Oh My Posh is the Windows prompt engine; it recreates this Powerlevel10k-style layout without installing Zsh.

PowerShell 5.1+ is required. Windows Terminal is optional. `winget` is needed when installing Oh My Posh. If Oh My Posh is already installed, `winget` is not needed. The script does not change execution policy. For Windows Terminal, open it once before running the installer so its settings file exists.

Options:

```powershell
.\scripts\powershell.ps1 -KeepDefaultProfile  # Preserve your current default Terminal profile
.\scripts\powershell.ps1 -SkipFontInstall    # You manage the required font yourself
.\scripts\powershell.ps1 -SkipPrompt         # Install only the Terminal appearance
.\scripts\powershell.ps1 -NoLaunch           # Configure without opening a new PowerShell window
.\scripts\powershell.ps1 -WhatIf             # Preview changes
.\scripts\powershell.ps1 -ExportPath .\terminal-preview
```

`-NoPrompt` skips optional questions; the Oh My Posh prompt and required font are installed by default unless skipped explicitly. The older `-InstallPrompt` switch remains accepted for compatibility.

Existing PowerShell initialization is preserved, with the marked SimplyHost Oh My Posh block taking precedence at its position in the profile. Files are backed up in `%LOCALAPPDATA%\SimplyHost\terminal-backups\`. To undo the setup, restore the saved Terminal settings or select your previous default, remove the SimplyHost fragment and console helper, and remove the SimplyHost marked blocks from the PowerShell profile. Other tools that replace the prompt later in your profile can override Oh My Posh.

## Maintenance

Edit the standalone scripts directly. The index discovers executable files and common script extensions anywhere under `scripts/` from GitHub when the page loads. Push additions, renames, or deletions to `main`; no index generation command is needed. Use Refresh on the page to reload the list. GitHub API availability and unauthenticated rate limits apply.

Cloudflare Pages can use `scripts` as the root directory, an empty build command, and `.` as the output directory. For existing projects that still run `node tools/build-script-index.mjs`, a small compatibility entry point verifies the index is present. It does not regenerate files. Internal deployment helpers under `tools/` are excluded from the public script list.

Keep inventory exports, local terminal exports, shell profiles, credentials, and backup archives outside the repository. Ignore rules cover common names, but review any files before committing.
