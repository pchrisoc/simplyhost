#!/bin/bash
set -euo pipefail
SCRIPT_NAME=inventory

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

if [[ ${1:-} == --help ]]; then echo 'Usage: inventory.sh [OUTPUT.json] — export local hardware and Proxmox inventory; defaults to stdout'; exit 0; fi
[[ $# -le 1 ]] || fail 'Usage: inventory.sh [OUTPUT.json]'
need python3
python3 - "${1:-}" <<'PY'
import datetime, json, os, platform, shutil, subprocess, sys, tempfile
from pathlib import Path
errors = []
def command(args):
    if not shutil.which(args[0]):
        return None
    try:
        p = subprocess.run(args, text=True, capture_output=True, timeout=30)
        if p.returncode:
            errors.append({'command': args[0], 'error': p.stderr.strip() or 'Command failed'})
            return None
        return p.stdout.strip()
    except (OSError, subprocess.TimeoutExpired) as e:
        errors.append({'command': args[0], 'error': str(e)})
def command_json(args):
    value = command(args)
    if value is None: return None
    try: return json.loads(value)
    except ValueError:
        errors.append({'command': args[0], 'error': 'Invalid JSON response'})
memory = None
if Path('/proc/meminfo').exists():
    memory = int(Path('/proc/meminfo').read_text().split('MemTotal:')[1].split()[0]) * 1024
elif platform.system() == 'Darwin':
    raw = command(['sysctl', '-n', 'hw.memsize'])
    memory = int(raw) if raw else None
usage = shutil.disk_usage('/')
result = {
    'schema_version': 1, 'collected_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'hostname': platform.node(), 'os': platform.system(), 'release': platform.release(),
    'architecture': platform.machine(), 'logical_cpus': os.cpu_count(), 'memory_bytes': memory,
    'root_filesystem': dict(zip(('total_bytes', 'used_bytes', 'free_bytes'), usage)),
    'block_devices': command_json(['lsblk', '--json', '--bytes', '-o', 'NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS']),
    'interfaces': command_json(['ip', '-json', 'address', 'show']),
    'routes': command_json(['ip', '-json', 'route', 'show']),
    'proxmox': {'version': command(['pveversion']),
        'vms': command_json(['pvesh', 'get', '/cluster/resources', '--type', 'vm', '--output-format', 'json']),
        'storage': command_json(['pvesh', 'get', '/storage', '--output-format', 'json'])},
    'errors': errors,
}
content = json.dumps(result, indent=2) + '\n'
if sys.argv[1]:
    target = Path(sys.argv[1]).absolute()
    # Exclusive creation preserves existing reports, including symlinks.
    fd = os.open(target, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, 'w') as f: f.write(content)
    print('Saved inventory to ' + str(target), file=sys.stderr)
else:
    print(content, end='')
PY
# Keep stdout valid JSON even when a shortcut is offered.
shortcut >&2
