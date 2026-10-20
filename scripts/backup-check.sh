#!/bin/bash
set -euo pipefail
SCRIPT_NAME=backup-check

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
  echo 'Usage: backup-check.sh [DESTINATION_DIRECTORY [MAX_AGE_HOURS]]'
  echo 'Checks every SimplyHost archive checksum and payload; checks newest backup age per source.'; exit 0
fi
need python3
[[ $# -le 2 ]] || fail 'See --help for usage.'
if [[ $# -eq 0 ]]; then prompt 'Backup destination directory'; destination=$REPLY; else destination=$1; fi
age=${2:-48}
[[ "$age" =~ ^[1-9][0-9]{0,5}$ ]] || fail 'Maximum age must be a positive number of hours.'
status=0
python3 - "$destination" "$age" <<'PY' || status=$?
import datetime, hashlib, json, re, sys, tarfile
from pathlib import Path
path = Path(sys.argv[1]).expanduser()
if not path.is_dir(): raise SystemExit('Backup directory does not exist.')
archives = sorted(path.glob('simplyhost-backup-*.tar.gz'))
if not archives: raise SystemExit('MISSING: no SimplyHost backups found.')
errors = 0
newest = {}
for archive in archives:
    try:
        if archive.is_symlink(): raise ValueError('Archive is a symlink')
        if not re.fullmatch(r'simplyhost-backup-[0-9a-f]{16}-[0-9]{8}T[0-9]{12}Z.tar.gz', archive.name):
            raise ValueError('Unexpected archive filename')
        meta = json.loads(Path(str(archive)+'.json').read_text())
        if not isinstance(meta['source'], str): raise ValueError('Invalid source')
        h = hashlib.sha256()
        with archive.open('rb') as f:
            for chunk in iter(lambda: f.read(1024*1024), b''): h.update(chunk)
        if h.hexdigest() != meta['sha256']: raise ValueError('Checksum mismatch')
        with tarfile.open(archive, 'r:gz') as tar:
            for member in tar:
                if member.isfile():
                    with tar.extractfile(member) as f:
                        while f.read(1024*1024): pass
        date = datetime.datetime.fromisoformat(meta['created_at'])
        age = (datetime.datetime.now(datetime.timezone.utc)-date).total_seconds()/3600
        if age < -1: raise ValueError('Backup date is in the future')
        newest[meta['source']] = min(newest.get(meta['source'], float('inf')), age)
        print('OK: '+archive.name)
    except (OSError, ValueError, KeyError, TypeError, tarfile.TarError, EOFError) as e:
        errors += 1; print('FAILED: '+archive.name+': '+str(e))
for source, age in newest.items():
    print(f'{"STALE" if age > int(sys.argv[2]) else "FRESH"}: {source} — {age:.1f} hours')
    if age > int(sys.argv[2]): errors += 1
raise SystemExit(1 if errors else 0)
PY
shortcut
exit "$status"
