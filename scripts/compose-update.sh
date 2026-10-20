#!/bin/bash
set -euo pipefail
SCRIPT_NAME=compose-update

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

heading() { printf '\n%s\n' "$*"; }

docker_ready() {
  need docker
  docker info >/dev/null 2>&1 || fail 'Docker is unavailable. Start it and check your Docker socket permissions.'
}

compose_ready() {
  docker_ready
  docker compose version >/dev/null 2>&1 || fail 'Docker Compose v2 is required.'
}

project_dir() {
  [[ -d "$1" ]] || fail "Directory does not exist: $1"
  cd -- "$1"
  [[ -f compose.yaml || -f compose.yml || -f docker-compose.yml || -f docker-compose.yaml ]] || fail 'No Compose file in this directory.'
  docker compose config --quiet
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
  echo 'Usage: compose-update.sh [PROJECT_DIRECTORY]'
  echo 'Interactive pull/update for running image-based services; saves config and rollback image tags.'
  echo 'Requires Compose v2 with up --wait support, Python 3, and a healthy running project.'
  echo 'Back up application data separately before upgrading; rollback does not undo data migrations.'; exit 0
fi
[[ $# -le 1 ]] || fail 'See --help for usage.'
compose_ready; need python3
if [[ $# -eq 0 ]]; then prompt 'Compose project directory'; directory=$REPLY; else directory=$1; fi
project_dir "$directory"
# Serializes SimplyHost updates for this project, without removing someone else's lock.
lock="$PWD/.simplyhost-update.lock"
mkdir "$lock" 2>/dev/null || fail 'An update lock exists. Check for an active update before removing .simplyhost-update.lock.'
trap 'rmdir -- "$lock"' EXIT
umask 077
staging=$(mktemp -d)
trap 'rm -rf -- "$staging"; rmdir -- "$lock"' EXIT
docker compose config --format json > "$staging/config.json"
python3 - "$staging/config.json" > "$staging/services" <<'PY'
import json, re, sys
config = json.load(open(sys.argv[1]))
for name, service in config['services'].items():
    if service.get('profiles'): raise SystemExit('Profile-based projects are not supported by this updater.')
    if service.get('build') or not service.get('image'): raise SystemExit('Use image-only projects; builds need their own release procedure.')
    if service.get('deploy', {}).get('replicas', 1) != 1: raise SystemExit('This updater supports one running container per service.')
    if not re.fullmatch('[a-zA-Z0-9][a-zA-Z0-9_.-]*', name): raise SystemExit('Unsupported service name.')
    print(name)
PY
[[ -s "$staging/services" ]] || fail 'No services found.'
heading 'Current services'; docker compose ps
heading 'Images to pull'; docker compose config --images
echo 'Application data must already be backed up. Image rollback cannot reverse database migrations.'
ask 'Save configuration and current images, then pull the configured image tags?' || exit 0
mkdir -p .simplyhost-updates
snapshot=$(mktemp -d "$PWD/.simplyhost-updates/update-$(date -u +%Y%m%dT%H%M%SZ)-XXXXXX")
chmod 700 "$snapshot"
cp "$staging/config.json" "$snapshot/config.json"
docker compose config > "$snapshot/compose.yaml"
# Save source files as a convenience; resolved compose.yaml also captures overrides and interpolation.
for file in compose.yaml compose.yml docker-compose.yaml docker-compose.yml compose.override.yaml compose.override.yml docker-compose.override.yaml docker-compose.override.yml .env; do
  if [[ -f "$file" ]]; then cp -- "$file" "$snapshot/source-${file#.}"; fi
done
project=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["name"])' "$snapshot/config.json")
printf 'services:\n' > "$snapshot/rollback.yaml"
while IFS= read -r service; do
  ids=$(docker compose ps --all --quiet "$service")
  [[ -n "$ids" && "$ids" != *$'\n'* ]] || fail "Service $service must have exactly one running container."
  state=$(docker inspect --format '{{.State.Status}} {{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' "$ids")
  [[ "$state" == 'running healthy' || "$state" == 'running no-healthcheck' ]] || fail "Service $service is not healthy: $state"
  image_id=$(docker inspect --format '{{.Image}}' "$ids")
  tag="simplyhost-rollback/$(printf '%s' "$project-$service" | tr '[:upper:]' '[:lower:]'):$(basename "$snapshot" | tr '[:upper:]' '[:lower:]')"
  docker image tag "$image_id" "$tag"
  python3 -c 'import json,sys; print("  "+json.dumps(sys.argv[1])+":\n    image: "+json.dumps(sys.argv[2])+"\n    pull_policy: never")' "$service" "$tag" >> "$snapshot/rollback.yaml"
done < "$staging/services"
printf '#!/bin/bash\nset -euo pipefail\ncd -- %q\ndocker compose --project-name %q --file %q --file %q up -d --pull never --no-build --wait --wait-timeout 120\n' \
  "$PWD" "$project" "$snapshot/compose.yaml" "$snapshot/rollback.yaml" > "$snapshot/rollback.sh"
chmod 700 "$snapshot/rollback.sh"
printf 'Saved configuration and rollback command in %s\n' "$snapshot"
docker compose pull
heading 'Pulled images'
docker compose config --images | while IFS= read -r image; do docker image inspect --format '{{.Id}} {{join .RepoTags ", "}}' "$image"; done
ask 'Recreate services with the pulled images and wait for health checks?' || exit 0
if docker compose up -d --pull never --no-build --wait --wait-timeout 120; then
  docker compose ps
  echo 'Update passed Compose readiness checks. Services without health checks only confirm running state.'
else
  printf 'Update failed. Inspect logs. After checking data migration compatibility, rollback with:\nbash %q\n' "$snapshot/rollback.sh" >&2
  exit 1
fi
shortcut
