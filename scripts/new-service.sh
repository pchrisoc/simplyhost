#!/bin/bash
set -euo pipefail
SCRIPT_NAME=new-service

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
  echo 'Usage: new-service.sh [DIRECTORY] — create a local-only web service scaffold interactively'
  echo 'Creates compose.yaml, .env, .gitignore, data/, and README.md; does not start containers.'; exit 0
fi
[[ $# -le 1 ]] || fail 'Usage: new-service.sh [DIRECTORY]'
need python3
if [[ $# -eq 1 ]]; then directory=$1; else prompt 'New project directory'; directory=$REPLY; fi
prompt 'Service name (lowercase letters, digits, hyphens; start with a letter)'; name=$REPLY
[[ "$name" =~ ^[a-z][a-z0-9-]*$ ]] || fail 'Invalid service name.'
prompt 'Container image including a tag or digest'; image=$REPLY
[[ "$image" =~ ^[a-zA-Z0-9][a-zA-Z0-9._/:@-]+$ && ( "$image" == *@sha256:* || "${image##*/}" == *:* ) ]] || fail 'Supply an image reference with a tag or digest.'
prompt 'Container HTTP port'; internal=$REPLY
prompt 'Host port (bound to 127.0.0.1)'; external=$REPLY
for port in "$internal" "$external"; do
  [[ "$port" =~ ^[0-9]{1,5}$ ]] && ((10#$port >= 1 && 10#$port <= 65535)) || fail 'Ports must be 1–65535.'
done
prompt 'Absolute container data directory (example /data)'; mount=$REPLY
[[ "$mount" =~ ^/[a-zA-Z0-9_./-]+$ && "$mount" != / ]] || fail 'Use an absolute container data directory other than /.'
prompt 'HTTP health URL inside container (example http://127.0.0.1:80/health)'; health=$REPLY
[[ "$health" =~ ^http://[a-zA-Z0-9.:/_?=%\&-]+$ ]] || fail 'Use an HTTP URL without credentials.'
echo 'The health check uses wget; select an image that includes wget or edit the check before starting.'
python3 - "$directory" "$name" "$image" "$((10#$internal))" "$((10#$external))" "$mount" "$health" <<'PY'
import json, os, sys
from pathlib import Path
path = Path(sys.argv[1]).absolute()
name, image, internal, external, mount, health = sys.argv[2:]
os.umask(0o077)
path.mkdir()  # Never overwrite an existing directory.
(path/'data').mkdir()
(path/'.env').write_text(f'IMAGE={image}\nHOST_PORT={external}\nCONTAINER_PORT={internal}\n')
# JSON strings are valid YAML scalars and avoid interpolating user text as YAML.
(path/'compose.yaml').write_text('services:\n  '+json.dumps(name)+':\n'
    '    image: "${IMAGE:?Set IMAGE in .env}"\n    restart: unless-stopped\n'
    '    ports:\n      - "127.0.0.1:${HOST_PORT}:${CONTAINER_PORT}"\n'
    '    volumes:\n      - type: bind\n        source: ./data\n        target: '+json.dumps(mount)+'\n'
    '    healthcheck:\n      test: '+json.dumps(['CMD', 'wget', '-q', '--spider', health])+'\n'
    '      interval: 30s\n      timeout: 5s\n      retries: 3\n      start_period: 30s\n')
(path/'.gitignore').write_text('.env\ndata/\n.simplyhost-updates/\n')
(path/'README.md').write_text(f'# {name}\n\n'
    'Review image requirements, data path and UID/GID permissions before starting.\n'
    'The health check requires wget in the image and a working HTTP endpoint.\n'
    'Only localhost can reach the published port.\n\n'
    'Start: `docker compose config --quiet && docker compose up -d --wait`\n\n'
    'Logs: `docker compose logs --tail 100 -f`\n\n'
    'Stop: `docker compose stop`\n\n'
    'Backup: stop the service or use its native database dump before archiving this directory.\n'
    'Configure retention and an independent backup destination. The .env file may contain secrets.\n')
print('Created ' + str(path))
PY
shortcut
