#!/usr/bin/env bash
set -euo pipefail

# ─── Konfiguration ───────────────────────────────────────────────────
PHP_VERSIONS=(7.4 8.0 8.1 8.2 8.3 8.4 8.5)

# Images mit PHP-Versionen (repo:version)
declare -A VERSIONED_IMAGES=(
  [php]="copex/php|php/Dockerfile|php"
  [nginx-php-fpm]="copex/nginx-php-fpm|nginx-php-fpm/Dockerfile|nginx-php-fpm"
)

# Images ohne Versionen (repo:latest)
declare -A SIMPLE_IMAGES=(
  [nginx]="copex/nginx|nginx/Dockerfile|nginx"
  [cron]="copex/cron|cron/Dockerfile|cron"
  [cron-ui]="copex/cron-ui|cron/ui/Dockerfile|cron/ui"
  [satis]="copex/satis|satis/Dockerfile|satis"
  [solr]="copex/solr|solr/Dockerfile|solr"
  [tools]="copex/tools|tools/Dockerfile|tools"
  [ci-capistrano]="copex/ci-capistrano|ci/capistrano/Dockerfile|ci/capistrano"
  [ci-gitlab]="copex/ci-gitlab|ci/gitlab/Dockerfile|ci/gitlab"
  [nginx-php-fpm-node]="copex/nginx-php-fpm-node|nginx-php-fpm/node/Dockerfile|nginx-php-fpm/node"
)

# ─── Optionen ────────────────────────────────────────────────────────
NO_CACHE_ARG=""
[[ "${NO_CACHE:-0}" == "1" ]] && NO_CACHE_ARG="--no-cache"

NO_PUSH="${NO_PUSH:-0}"

# ─── Hilfsfunktionen ────────────────────────────────────────────────
fail_count=0

build_and_push() {
  local repo="$1" dockerfile="$2" context="$3" tag="$4"
  local build_args=("${@:5}")

  echo "=============================="
  echo ">> Baue ${repo}:${tag}"
  echo "=============================="

  if docker build ${NO_CACHE_ARG} "${build_args[@]}" \
      -f "${dockerfile}" -t "${repo}:${tag}" "${context}"; then
    echo ">> Build ok: ${repo}:${tag}"
  else
    echo "!! Build fehlgeschlagen: ${repo}:${tag}"
    ((fail_count++)) || true
    return 1
  fi

  if [[ "${NO_PUSH}" == "1" ]]; then
    echo ">> Push übersprungen (NO_PUSH=1)"
  elif docker push "${repo}:${tag}"; then
    echo ">> Push ok: ${repo}:${tag}"
  else
    echo "!! Push fehlgeschlagen: ${repo}:${tag}"
    ((fail_count++)) || true
  fi
  echo
}

build_versioned() {
  local name="$1" version="${2:-}"
  local config="${VERSIONED_IMAGES[$name]}"
  IFS='|' read -r repo dockerfile context <<< "$config"

  local versions=("${PHP_VERSIONS[@]}")
  [[ -n "$version" ]] && versions=("$version")

  for v in "${versions[@]}"; do
    build_and_push "$repo" "$dockerfile" "$context" "$v" --build-arg "PHP_VERSION=${v}"
  done
}

build_simple() {
  local name="$1"
  local config="${SIMPLE_IMAGES[$name]}"
  IFS='|' read -r repo dockerfile context <<< "$config"
  build_and_push "$repo" "$dockerfile" "$context" "latest"
}

usage() {
  cat <<'EOF'
Verwendung: ./build.sh <image> [version]

Images mit PHP-Versionen:
  php [version]             z.B. ./build.sh php 8.5
  nginx-php-fpm [version]   z.B. ./build.sh nginx-php-fpm 8.3

Images ohne Versionen:
  nginx, cron, cron-ui, satis, solr, tools,
  ci-capistrano, ci-gitlab, nginx-php-fpm-node

Spezial:
  all                       Baut alles
  all-php                   Baut php + nginx-php-fpm (alle Versionen)

Optionen (ENV):
  NO_CACHE=1                Ohne Docker-Cache bauen
  NO_PUSH=1                 Nur bauen, nicht pushen

Beispiele:
  ./build.sh php 8.5                   # Nur PHP 8.5
  ./build.sh nginx-php-fpm 8.4        # Nur nginx-php-fpm 8.4
  ./build.sh nginx                     # Nginx (latest)
  NO_CACHE=1 ./build.sh php            # Alle PHP-Versionen ohne Cache
  NO_PUSH=1 ./build.sh all-php         # Alle PHP-Images nur bauen
  ./build.sh all                       # Alles bauen und pushen
EOF
  exit 0
}

# ─── Main ────────────────────────────────────────────────────────────
[[ $# -eq 0 ]] && usage

IMAGE="${1:-}"
VERSION="${2:-}"

ALL_VERSIONED=(php nginx-php-fpm)
ALL_SIMPLE=(nginx cron cron-ui satis solr tools ci-capistrano ci-gitlab nginx-php-fpm-node)

case "$IMAGE" in
  -h|--help|help)
    usage
    ;;
  all)
    for name in "${ALL_VERSIONED[@]}"; do build_versioned "$name"; done
    for name in "${ALL_SIMPLE[@]}"; do build_simple "$name"; done
    ;;
  all-php)
    for name in "${ALL_VERSIONED[@]}"; do build_versioned "$name"; done
    ;;
  *)
    if [[ -n "${VERSIONED_IMAGES[$IMAGE]+x}" ]]; then
      build_versioned "$IMAGE" "$VERSION"
    elif [[ -n "${SIMPLE_IMAGES[$IMAGE]+x}" ]]; then
      build_simple "$IMAGE"
    else
      echo "Unbekanntes Image: $IMAGE"
      echo
      usage
    fi
    ;;
esac

if (( fail_count > 0 )); then
  echo "Fertig mit ${fail_count} Fehler(n)."
  exit 1
fi

echo "Erfolgreich abgeschlossen."
