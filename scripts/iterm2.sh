#!/bin/bash
set -euo pipefail
SCRIPT_NAME=iterm2

fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }

need() { command -v "$1" >/dev/null 2>&1 || fail "Required command missing: $1"; }

interactive() { [[ -t 2 ]] && ( : </dev/tty ) 2>/dev/null; }

ask() {
  interactive || return 1
  local answer
  printf '%s [y/N] ' "$1" >&2
  IFS= read -r answer </dev/tty || return 1
  [[ "$answer" == y || "$answer" == Y || "$answer" == yes ]]
}

prompt() {
  interactive || fail "Supply arguments when running without a terminal; see --help."
  printf '%s: ' "$1" >&2
  IFS= read -r REPLY </dev/tty || fail 'Input cancelled.'
  [[ -n "$REPLY" ]] || fail 'A value is required.'
}

shortcut() {
  [[ ${SIMPLYHOST_NO_SHORTCUT:-0} == 1 ]] && return 0
  local name="sh-$SCRIPT_NAME" target base line source_path staging
  ask "Add command '$name' to ~/.bashrc for repeat use?" || return 0
  base="$HOME/.local/share/simplyhost/scripts"
  target="$base/$SCRIPT_NAME.sh"
  mkdir -p "$base"
  staging=$(mktemp "$base/.install.XXXXXX")
  source_path=${BASH_SOURCE[0]:-}
  if [[ -f "$source_path" ]]; then
    cp -- "$source_path" "$staging"
  else
    need curl
    if ! curl -fsSL "https://scripts.simplyhost.org/$SCRIPT_NAME.sh" -o "$staging"; then
      rm -f -- "$staging"; fail 'Could not save the script for repeat use.'
    fi
  fi
  if ! bash -n "$staging"; then rm -f -- "$staging"; fail 'Downloaded script failed syntax validation.'; fi
  chmod 700 "$staging"
  mv -f -- "$staging" "$target"
  printf -v line '%s() { SIMPLYHOST_NO_SHORTCUT=1 bash %q "$@"; }' "$name" "$target"
  if [[ ! -f "$HOME/.bashrc" ]] || ! grep -Fqx -- "$line" "$HOME/.bashrc"; then
    printf '\n# SimplyHost: %s\n%s\n' "$name" "$line" >> "$HOME/.bashrc"
  fi
  printf 'Saved %s. Open a new Bash shell or run: source ~/.bashrc\n' "$name"
}

if [[ ${1:-} == --help ]]; then
  echo 'Usage: iterm2.sh [--install | --apply-globals | --export DIRECTORY]'
  echo 'Installs the captured SimplyHost dynamic profile. Global settings require iTerm2 to be closed.'
  echo 'Export writes portable profile, global settings and Windows Terminal JSON without changing preferences.'; exit 0
fi
mode=${1:---install}
case "$mode" in
  --install|--apply-globals) [[ $# -le 1 ]] || fail 'See --help.' ;;
  --export) [[ $# -eq 2 ]] || fail 'Usage: iterm2.sh --export NEW_DIRECTORY' ;;
  *) fail 'See --help for usage.' ;;
esac
need python3
payload=$(cat <<'PRESET'
{
  "schema_version": 1,
  "iterm2": {
    "Profiles": [
      {
        "ASCII Anti Aliased": true,
        "ASCII Ligatures": true,
        "Ansi 0 Color": {
          "Blue Component": 0.0,
          "Green Component": 0.0,
          "Red Component": 0.0
        },
        "Ansi 0 Color (Dark)": {
          "Blue Component": 0.25882352941176473,
          "Color Space": "sRGB",
          "Green Component": 0.21176470588235294,
          "Red Component": 0.027450980392156862
        },
        "Ansi 0 Color (Light)": {
          "Blue Component": 0.0,
          "Green Component": 0.0,
          "Red Component": 0.0
        },
        "Ansi 1 Color": {
          "Blue Component": 0.0,
          "Green Component": 0.0,
          "Red Component": 0.7333333492279053
        },
        "Ansi 1 Color (Dark)": {
          "Blue Component": 0.1843137254901961,
          "Color Space": "sRGB",
          "Green Component": 0.19607843137254902,
          "Red Component": 0.8627450980392157
        },
        "Ansi 1 Color (Light)": {
          "Blue Component": 0.0,
          "Green Component": 0.0,
          "Red Component": 0.7333333492279053
        },
        "Ansi 10 Color": {
          "Blue Component": 0.3333333432674408,
          "Green Component": 1.0,
          "Red Component": 0.3333333432674408
        },
        "Ansi 10 Color (Dark)": {
          "Blue Component": 0.4588235294117647,
          "Color Space": "sRGB",
          "Green Component": 0.43137254901960786,
          "Red Component": 0.34509803921568627
        },
        "Ansi 10 Color (Light)": {
          "Blue Component": 0.3333333432674408,
          "Green Component": 1.0,
          "Red Component": 0.3333333432674408
        },
        "Ansi 11 Color": {
          "Blue Component": 0.3333333432674408,
          "Green Component": 1.0,
          "Red Component": 1.0
        },
        "Ansi 11 Color (Dark)": {
          "Blue Component": 0.5137254901960784,
          "Color Space": "sRGB",
          "Green Component": 0.4823529411764706,
          "Red Component": 0.396078431372549
        },
        "Ansi 11 Color (Light)": {
          "Blue Component": 0.3333333432674408,
          "Green Component": 1.0,
          "Red Component": 1.0
        },
        "Ansi 12 Color": {
          "Blue Component": 1.0,
          "Green Component": 0.3333333432674408,
          "Red Component": 0.3333333432674408
        },
        "Ansi 12 Color (Dark)": {
          "Blue Component": 0.5882352941176471,
          "Color Space": "sRGB",
          "Green Component": 0.5803921568627451,
          "Red Component": 0.5137254901960784
        },
        "Ansi 12 Color (Light)": {
          "Blue Component": 1.0,
          "Green Component": 0.3333333432674408,
          "Red Component": 0.3333333432674408
        },
        "Ansi 13 Color": {
          "Blue Component": 1.0,
          "Green Component": 0.3333333432674408,
          "Red Component": 1.0
        },
        "Ansi 13 Color (Dark)": {
          "Blue Component": 0.7686274509803922,
          "Color Space": "sRGB",
          "Green Component": 0.44313725490196076,
          "Red Component": 0.4235294117647059
        },
        "Ansi 13 Color (Light)": {
          "Blue Component": 1.0,
          "Green Component": 0.3333333432674408,
          "Red Component": 1.0
        },
        "Ansi 14 Color": {
          "Blue Component": 1.0,
          "Green Component": 1.0,
          "Red Component": 0.3333333432674408
        },
        "Ansi 14 Color (Dark)": {
          "Blue Component": 0.6313725490196078,
          "Color Space": "sRGB",
          "Green Component": 0.6313725490196078,
          "Red Component": 0.5764705882352941
        },
        "Ansi 14 Color (Light)": {
          "Blue Component": 1.0,
          "Green Component": 1.0,
          "Red Component": 0.3333333432674408
        },
        "Ansi 15 Color": {
          "Blue Component": 1.0,
          "Green Component": 1.0,
          "Red Component": 1.0
        },
        "Ansi 15 Color (Dark)": {
          "Blue Component": 0.8901960784313725,
          "Color Space": "sRGB",
          "Green Component": 0.9647058823529412,
          "Red Component": 0.9921568627450981
        },
        "Ansi 15 Color (Light)": {
          "Blue Component": 1.0,
          "Green Component": 1.0,
          "Red Component": 1.0
        },
        "Ansi 2 Color": {
          "Blue Component": 0.0,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.0
        },
        "Ansi 2 Color (Dark)": {
          "Blue Component": 0.0,
          "Color Space": "sRGB",
          "Green Component": 0.6,
          "Red Component": 0.5215686274509804
        },
        "Ansi 2 Color (Light)": {
          "Blue Component": 0.0,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.0
        },
        "Ansi 3 Color": {
          "Blue Component": 0.0,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.7333333492279053
        },
        "Ansi 3 Color (Dark)": {
          "Blue Component": 0.0,
          "Color Space": "sRGB",
          "Green Component": 0.5372549019607843,
          "Red Component": 0.7098039215686275
        },
        "Ansi 3 Color (Light)": {
          "Blue Component": 0.0,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.7333333492279053
        },
        "Ansi 4 Color": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.0,
          "Red Component": 0.0
        },
        "Ansi 4 Color (Dark)": {
          "Blue Component": 0.8235294117647058,
          "Color Space": "sRGB",
          "Green Component": 0.5450980392156862,
          "Red Component": 0.14901960784313725
        },
        "Ansi 4 Color (Light)": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.0,
          "Red Component": 0.0
        },
        "Ansi 5 Color": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.0,
          "Red Component": 0.7333333492279053
        },
        "Ansi 5 Color (Dark)": {
          "Blue Component": 0.5098039215686274,
          "Color Space": "sRGB",
          "Green Component": 0.21176470588235294,
          "Red Component": 0.8274509803921568
        },
        "Ansi 5 Color (Light)": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.0,
          "Red Component": 0.7333333492279053
        },
        "Ansi 6 Color": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.0
        },
        "Ansi 6 Color (Dark)": {
          "Blue Component": 0.596078431372549,
          "Color Space": "sRGB",
          "Green Component": 0.6313725490196078,
          "Red Component": 0.16470588235294117
        },
        "Ansi 6 Color (Light)": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.0
        },
        "Ansi 7 Color": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.7333333492279053
        },
        "Ansi 7 Color (Dark)": {
          "Blue Component": 0.8352941176470589,
          "Color Space": "sRGB",
          "Green Component": 0.9098039215686274,
          "Red Component": 0.9333333333333333
        },
        "Ansi 7 Color (Light)": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.7333333492279053
        },
        "Ansi 8 Color": {
          "Blue Component": 0.3333333432674408,
          "Green Component": 0.3333333432674408,
          "Red Component": 0.3333333432674408
        },
        "Ansi 8 Color (Dark)": {
          "Blue Component": 0.21176470588235294,
          "Color Space": "sRGB",
          "Green Component": 0.16862745098039217,
          "Red Component": 0.0
        },
        "Ansi 8 Color (Light)": {
          "Blue Component": 0.3333333432674408,
          "Green Component": 0.3333333432674408,
          "Red Component": 0.3333333432674408
        },
        "Ansi 9 Color": {
          "Blue Component": 0.3333333432674408,
          "Green Component": 0.3333333432674408,
          "Red Component": 1.0
        },
        "Ansi 9 Color (Dark)": {
          "Blue Component": 0.08627450980392157,
          "Color Space": "sRGB",
          "Green Component": 0.29411764705882354,
          "Red Component": 0.796078431372549
        },
        "Ansi 9 Color (Light)": {
          "Blue Component": 0.3333333432674408,
          "Green Component": 0.3333333432674408,
          "Red Component": 1.0
        },
        "Background Color": {
          "Alpha Component": 1.0,
          "Blue Component": 0.25177001953125,
          "Color Space": "sRGB",
          "Green Component": 0.0867764497518389,
          "Red Component": 0.0
        },
        "Background Color (Dark)": {
          "Blue Component": 0.21176470588235294,
          "Color Space": "sRGB",
          "Green Component": 0.16862745098039217,
          "Red Component": 0.0
        },
        "Background Color (Light)": {
          "Alpha Component": 1.0,
          "Blue Component": 0.25177001953125,
          "Color Space": "sRGB",
          "Green Component": 0.0867764497518389,
          "Red Component": 0.0
        },
        "Blinking Cursor": false,
        "Blur": false,
        "Bold Color": {
          "Blue Component": 1.0,
          "Green Component": 1.0,
          "Red Component": 1.0
        },
        "Bold Color (Dark)": {
          "Blue Component": 0.6313725490196078,
          "Color Space": "sRGB",
          "Green Component": 0.6313725490196078,
          "Red Component": 0.5764705882352941
        },
        "Bold Color (Light)": {
          "Blue Component": 1.0,
          "Green Component": 1.0,
          "Red Component": 1.0
        },
        "Brighten Bold Text (Dark)": true,
        "Brighten Bold Text (Light)": true,
        "Columns": 80,
        "Cursor Color": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.7333333492279053
        },
        "Cursor Color (Dark)": {
          "Blue Component": 0.5882352941176471,
          "Color Space": "sRGB",
          "Green Component": 0.5803921568627451,
          "Red Component": 0.5137254901960784
        },
        "Cursor Color (Light)": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.7333333492279053
        },
        "Cursor Text Color": {
          "Blue Component": 1.0,
          "Green Component": 1.0,
          "Red Component": 1.0
        },
        "Cursor Text Color (Dark)": {
          "Blue Component": 0.25882352941176473,
          "Color Space": "sRGB",
          "Green Component": 0.21176470588235294,
          "Red Component": 0.027450980392156862
        },
        "Cursor Text Color (Light)": {
          "Blue Component": 1.0,
          "Green Component": 1.0,
          "Red Component": 1.0
        },
        "Faint Text Alpha (Dark)": 0.5,
        "Faint Text Alpha (Light)": 0.5,
        "Foreground Color": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.7333333492279053
        },
        "Foreground Color (Dark)": {
          "Alpha Component": 1.0,
          "Blue Component": 0.7235107421875,
          "Color Space": "P3",
          "Green Component": 0.7119658875832515,
          "Red Component": 0.6384523889862794
        },
        "Foreground Color (Light)": {
          "Blue Component": 0.7333333492279053,
          "Green Component": 0.7333333492279053,
          "Red Component": 0.7333333492279053
        },
        "Horizontal Spacing": 1.0,
        "Link Color (Dark)": {
          "Alpha Component": 1.0,
          "Blue Component": 0.7093239426612854,
          "Color Space": "P3",
          "Green Component": 0.35333043336868286,
          "Red Component": 0.14513972401618958
        },
        "Link Color (Light)": {
          "Alpha Component": 1.0,
          "Blue Component": 0.7093239426612854,
          "Color Space": "P3",
          "Green Component": 0.35333043336868286,
          "Red Component": 0.14513972401618958
        },
        "Load Shell Integration Automatically": true,
        "Non Ascii Font": "Monaco 15",
        "Non-ASCII Anti Aliased": true,
        "Normal Font": "JetBrainsMonoNFM-Regular 15",
        "Option Key Sends": 0,
        "Right Option Key Sends": 0,
        "Rows": 25,
        "Scrollback Lines": 1000,
        "Selected Text Color": {
          "Blue Component": 0.0,
          "Green Component": 0.0,
          "Red Component": 0.0
        },
        "Selected Text Color (Dark)": {
          "Blue Component": 0.6313725490196078,
          "Color Space": "sRGB",
          "Green Component": 0.6313725490196078,
          "Red Component": 0.5764705882352941
        },
        "Selected Text Color (Light)": {
          "Blue Component": 0.0,
          "Green Component": 0.0,
          "Red Component": 0.0
        },
        "Selection Color": {
          "Blue Component": 1.0,
          "Green Component": 0.8353000283241272,
          "Red Component": 0.7098000049591064
        },
        "Selection Color (Dark)": {
          "Blue Component": 0.25882352941176473,
          "Color Space": "sRGB",
          "Green Component": 0.21176470588235294,
          "Red Component": 0.027450980392156862
        },
        "Selection Color (Light)": {
          "Blue Component": 1.0,
          "Green Component": 0.8353000283241272,
          "Red Component": 0.7098000049591064
        },
        "Sync Title": false,
        "Transparency": 0.0,
        "Unlimited Scrollback": false,
        "Use Bold Font": true,
        "Use Bright Bold": true,
        "Use Non-ASCII Font": false,
        "Use Selected Text Color (Dark)": true,
        "Use Selected Text Color (Light)": true,
        "Use Separate Colors for Light and Dark Mode": true,
        "Vertical Spacing": 1.0,
        "Name": "SimplyHost iTerm2",
        "Guid": "a4692b4e-5b6a-5b9a-b0f0-6661e5147f71",
        "Command": "/bin/zsh",
        "Custom Command": "Yes",
        "Custom Directory": "No",
        "Working Directory": "",
        "Initial Text": "",
        "Send Text at Start": "",
        "Triggers": [],
        "Keyboard Map": {},
        "Tags": [
          "SimplyHost"
        ],
        "Dynamic Profile Parent Name": "Default"
      }
    ]
  },
  "iterm2_globals": {
    "DimBackgroundWindows": false,
    "DimOnlyText": false,
    "HideScrollbar": true,
    "SeparateStatusBarsPerPane": false,
    "ShowFullScreenTabBar": false,
    "ShowPaneTitles": true,
    "SplitPaneDimmingAmount": 0.39714711013349513,
    "StretchTabsToFillBar": true,
    "TabStyleWithAutomaticOption": 5,
    "TabViewType": 0,
    "TabsHaveCloseButton": true,
    "UseBorder": false
  },
  "windows_terminal": {
    "profiles": [
      {
        "guid": "{8cecb952-ffa0-50a6-a799-f858602245a2}",
        "name": "SimplyHost PowerShell",
        "commandline": "powershell.exe -NoLogo",
        "startingDirectory": "%USERPROFILE%",
        "font": {
          "face": "JetBrainsMono Nerd Font Mono",
          "size": 15,
          "features": {
            "liga": 1
          }
        },
        "colorScheme": {
          "light": "SimplyHost iTerm2 Light",
          "dark": "SimplyHost iTerm2 Dark"
        },
        "opacity": 100,
        "useAcrylic": false,
        "historySize": 1000,
        "scrollbarState": "hidden",
        "intenseTextStyle": "all"
      }
    ],
    "schemes": [
      {
        "name": "SimplyHost iTerm2 Light",
        "black": "#000000",
        "red": "#BB0000",
        "green": "#00BB00",
        "yellow": "#BBBB00",
        "blue": "#0000BB",
        "purple": "#BB00BB",
        "cyan": "#00BBBB",
        "white": "#BBBBBB",
        "brightBlack": "#555555",
        "brightRed": "#FF5555",
        "brightGreen": "#55FF55",
        "brightYellow": "#FFFF55",
        "brightBlue": "#5555FF",
        "brightPurple": "#FF55FF",
        "brightCyan": "#55FFFF",
        "brightWhite": "#FFFFFF",
        "background": "#001640",
        "foreground": "#BBBBBB",
        "cursorColor": "#BBBBBB",
        "selectionBackground": "#B5D5FF"
      },
      {
        "name": "SimplyHost iTerm2 Dark",
        "black": "#073642",
        "red": "#DC322F",
        "green": "#859900",
        "yellow": "#B58900",
        "blue": "#268BD2",
        "purple": "#D33682",
        "cyan": "#2AA198",
        "white": "#EEE8D5",
        "brightBlack": "#002B36",
        "brightRed": "#CB4B16",
        "brightGreen": "#586E75",
        "brightYellow": "#657B83",
        "brightBlue": "#839496",
        "brightPurple": "#6C71C4",
        "brightCyan": "#93A1A1",
        "brightWhite": "#FDF6E3",
        "background": "#002B36",
        "foreground": "#A3B6B8",
        "cursorColor": "#839496",
        "selectionBackground": "#073642"
      }
    ]
  },
  "notes": {
    "color_conversion": "Normalized RGB channels rounded to 8-bit; Display P3 colors are approximated.",
    "shell": "iTerm2 uses /bin/zsh. PowerShell prompt is a native approximation of directory, Git and status segments."
  }
}
PRESET
)
if [[ "$mode" != --export ]]; then [[ $(uname -s) == Darwin ]] || fail 'iTerm2 installation requires macOS. Use --export to inspect the preset elsewhere.'; fi
# Environment carries only the portable allowlisted JSON, not local preferences.
SIMPLYHOST_TERMINAL_PRESET="$payload" python3 - "$mode" "${2:-}" <<'PY'
import datetime, json, os, shutil, subprocess, sys, tempfile
from pathlib import Path
preset = json.loads(os.environ['SIMPLYHOST_TERMINAL_PRESET'])
mode = sys.argv[1]
os.umask(0o077)
def write_json(target, value):
    content = json.dumps(value, indent=2)+'\n'
    if target.exists() and target.read_text() == content:
        print('Already current: '+str(target)); return
    # Backups live outside DynamicProfiles, which scans every file, regardless of extension.
    if target.exists():
        backups = Path.home()/'.local/share/simplyhost/terminal-backups'
        backups.mkdir(parents=True, exist_ok=True)
        stamp = datetime.datetime.now().strftime('%Y%m%dT%H%M%S%f')
        shutil.copy2(target, backups/(target.name+'.'+stamp+'.bak'))
    fd, temporary = tempfile.mkstemp(dir=target.parent, prefix='.simplyhost-')
    try:
        with os.fdopen(fd, 'w') as f: f.write(content)
        os.replace(temporary, target)
    finally:
        if os.path.exists(temporary): os.unlink(temporary)
    print('Saved '+str(target))
if mode == '--export':
    directory = Path(sys.argv[2]).expanduser()
    directory.mkdir()  # Exclusive directory creation avoids replacing existing exports.
    for filename,key in [('iterm2-profile.json','iterm2'), ('iterm2-globals.json','iterm2_globals'),
                         ('windows-terminal.json','windows_terminal')]:
        write_json(directory/filename, preset[key])
elif mode == '--install':
    directory = Path.home()/'Library/Application Support/iTerm2/DynamicProfiles'
    directory.mkdir(parents=True, exist_ok=True)
    write_json(directory/'simplyhost.json', preset['iterm2'])
    print('Select “SimplyHost iTerm2” from the Profiles menu. Font: JetBrainsMono Nerd Font Mono, 15 pt.')
    print('For application-wide settings, quit iTerm2 and run this script with --apply-globals from Terminal.app.')
else:
    # iTerm caches preferences and can overwrite defaults on exit; never write globals while it runs.
    running = subprocess.run(['pgrep','-x','iTerm2'], capture_output=True)
    if running.returncode == 0: raise SystemExit('Quit iTerm2 first, then run --apply-globals from Terminal.app.')
    if running.returncode != 1: raise SystemExit('Could not check whether iTerm2 is running.')
    backup_directory = Path.home()/'.local/share/simplyhost/terminal-backups'
    backup_directory.mkdir(parents=True, exist_ok=True)
    stamp = datetime.datetime.now().strftime('%Y%m%dT%H%M%S%f')
    backup = backup_directory/('iterm2-preferences-'+stamp+'.plist')
    result = subprocess.run(['defaults','export','com.googlecode.iterm2','-'], capture_output=True, check=True)
    backup.write_bytes(result.stdout)
    for key,value in preset['iterm2_globals'].items():
        kind = '-bool' if isinstance(value,bool) else '-int' if isinstance(value,int) else '-float'
        text = str(value).lower() if isinstance(value,bool) else str(value)
        subprocess.run(['defaults','write','com.googlecode.iterm2',key,kind,text], check=True)
    print('Applied global appearance settings. Preferences backup: '+str(backup))
    print('Reopen iTerm2. Existing profiles and the default profile selection are preserved.')
PY
if [[ "$mode" == --install ]]; then
  echo 'Install JetBrains Mono Nerd Font separately if it is missing: https://www.nerdfonts.com/font-downloads'
  shortcut
fi
