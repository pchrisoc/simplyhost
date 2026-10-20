#!/bin/bash
set -euo pipefail
SCRIPT_NAME=backup

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
  echo 'Usage: backup.sh [SOURCE_DIRECTORY DESTINATION_DIRECTORY KEEP_COUNT]'
  echo 'Creates and verifies a timestamped tar.gz archive; retention applies to this source only.'
  echo 'No arguments prompts for paths. Quiesce databases first; live files are not application-consistent.'; exit 0
fi
need python3
if [[ $# -eq 0 ]]; then
  prompt 'Source directory'; source_directory=$REPLY
  prompt 'Backup destination directory'; destination=$REPLY
  prompt 'Number of successful backups to retain'; keep=$REPLY
else
  [[ $# -eq 3 ]] || fail 'See --help for usage.'
  source_directory=$1; destination=$2; keep=$3
fi
[[ "$keep" =~ ^[1-9][0-9]{0,5}$ ]] || fail 'Retention must be a positive integer (up to 999999).'
echo 'Archiving files as they are now; stop writers or create native database dumps first.'
python3 - "$source_directory" "$destination" "$keep" <<'PY'
import datetime, fcntl, hashlib, json, os, tarfile, tempfile, sys
from pathlib import Path
source, dest = (Path(p).expanduser().resolve() for p in sys.argv[1:3])
keep = int(sys.argv[3])
if not source.is_dir(): raise SystemExit('Source is not a directory.')
if dest == source or source in dest.parents: raise SystemExit('Backup destination must be outside the source.')
os.umask(0o077)
dest.mkdir(parents=True, exist_ok=True)
key = hashlib.sha256(str(source).encode()).hexdigest()[:16]
lock = (dest/('.simplyhost-'+key+'.lock')).open('a')
try: fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
except BlockingIOError: raise SystemExit('A backup of this source is already running.')
# A private staging directory keeps incomplete archives out of backup-check/retention.
with tempfile.TemporaryDirectory(prefix='.simplyhost-', dir=dest) as temporary:
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    name = f'simplyhost-backup-{key}-{stamp}.tar.gz'
    archive = Path(temporary)/name
    with tarfile.open(archive, 'w:gz', dereference=False) as tar:
        tar.add(source, arcname='data', recursive=True)
    # Reading every byte validates gzip CRC and tar payload readability.
    with tarfile.open(archive, 'r:gz') as tar:
        for member in tar:
            if member.isfile():
                with tar.extractfile(member) as f:
                    while f.read(1024*1024): pass
    digest = hashlib.file_digest(archive.open('rb'), 'sha256').hexdigest() if hasattr(hashlib, 'file_digest') else None
    if digest is None:
        h = hashlib.sha256()
        with archive.open('rb') as f:
            for chunk in iter(lambda: f.read(1024*1024), b''): h.update(chunk)
        digest = h.hexdigest()
    metadata = {'schema_version':1, 'source':str(source), 'created_at':datetime.datetime.now(datetime.timezone.utc).isoformat(), 'sha256':digest}
    sidecar = Path(temporary)/(name+'.json')
    sidecar.write_text(json.dumps(metadata, indent=2)+'\n')
    archive.rename(dest/name)
    sidecar.rename(dest/sidecar.name)
# Only prune matching, complete SimplyHost archives after a verified backup succeeds.
archives = sorted(p for p in dest.glob(f'simplyhost-backup-{key}-*.tar.gz') if not p.is_symlink() and p.is_file() and Path(str(p)+'.json').is_file())
for old in archives[:-keep]:
    old.unlink(); Path(str(old)+'.json').unlink()
    print('Pruned '+old.name)
print('Verified backup: '+str(dest/name))
print('Restore into an empty directory: tar -xzf ARCHIVE -C EMPTY_DIRECTORY (files are under data/).')
PY
shortcut
