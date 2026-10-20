#!/bin/bash
set -euo pipefail
SCRIPT_NAME=docker

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

linux_only() { [[ $(uname -s) == Linux ]] || fail 'This tool requires Linux.'; }

root_run() {
  if [[ $EUID -eq 0 ]]; then "$@"; else need sudo; sudo -- "$@"; fi
}

if [[ ${1:-} == --help ]]; then
  echo 'Usage: docker.sh — interactive Docker Engine + Compose installation for Debian/Ubuntu guests'
  echo 'Uses the official Docker apt repository. Existing working installations are verified.'; exit 0
fi
[[ $# -eq 0 ]] || fail 'Usage: docker.sh'
linux_only
[[ ! -e /etc/pve ]] || fail 'Run this inside a guest, not on the Proxmox host.'
[[ -r /etc/os-release ]] || fail 'Cannot detect Linux distribution.'
. /etc/os-release
case "$ID" in debian|ubuntu) ;; *) fail 'Supported guests: Debian and Ubuntu.' ;; esac
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  root_run docker info >/dev/null
  docker --version; docker compose version
  echo 'Existing Docker and Compose installation verified.'; exit 0
fi
need apt-get; need dpkg
conflicts=''
for package in docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc; do
  if [[ $(dpkg-query -W -f='${Status}' "$package" 2>/dev/null || true) == 'install ok installed' ]]; then conflicts="$conflicts $package"; fi
done
[[ -z "$conflicts" ]] || fail "Resolve conflicting packages before installing:$conflicts. Existing packages were preserved."
codename=${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}
[[ "$codename" =~ ^[a-z][a-z0-9-]*$ ]] || fail 'Cannot determine distribution codename.'
[[ ! -e /etc/apt/sources.list.d/docker.sources && ! -e /etc/apt/sources.list.d/docker.list && ! -e /etc/apt/keyrings/docker.asc ]] || fail 'Docker repository configuration already exists; review it before retrying.'
printf 'Install Docker Engine, Buildx and Compose from download.docker.com/linux/%s (%s).\n' "$ID" "$codename"
echo 'Published container ports can bypass ufw rules. The Docker service will start automatically.'
ask 'Proceed with installation?' || exit 0
root_run apt-get update
root_run apt-get install -y ca-certificates curl
staging=$(mktemp -d); trap 'rm -rf -- "$staging"' EXIT
curl -fsSL "https://download.docker.com/linux/$ID/gpg" -o "$staging/docker.asc"
[[ -s "$staging/docker.asc" ]] || fail 'Docker signing key is empty.'
cat > "$staging/docker.sources" <<REPO
Types: deb
URIs: https://download.docker.com/linux/$ID
Suites: $codename
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
REPO
root_run install -m 0755 -d /etc/apt/keyrings
root_run install -m 0644 "$staging/docker.asc" /etc/apt/keyrings/docker.asc
root_run install -m 0644 "$staging/docker.sources" /etc/apt/sources.list.d/docker.sources
root_run apt-get update
root_run apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
if [[ -d /run/systemd/system ]]; then root_run systemctl enable --now docker; fi
root_run docker info >/dev/null
root_run docker compose version
root_run docker run --rm hello-world
printf '\nDocker verified. Use sudo docker unless your account already has Docker access.\n'
