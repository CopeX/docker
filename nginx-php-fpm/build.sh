#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Usage:
#   ./build.sh build [VERSION...]   – nur bauen
#   ./build.sh push  [VERSION...]   – nur pushen
#   ./build.sh all   [VERSION...]   – bauen + pushen (default)
#
# Beispiele:
#   ./build.sh build 8.3 8.4        – nur PHP 8.3 und 8.4 bauen
#   ./build.sh push                  – alle Versionen pushen
#   ./build.sh                       – alle Versionen bauen + pushen
#
# ENV-Variablen:
#   REPO        – Image-Prefix      (default: copex/nginx-php-fpm:dev-)
#   DOCKERFILE  – Dockerfile-Pfad   (default: Dockerfile)
#   CONTEXT     – Build-Context     (default: .)
#   NO_CACHE    – 1 = --no-cache    (default: 0)
# ---------------------------------------------------------------------------

REPO="${REPO:-copex/nginx-php-fpm:dev-}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"
CONTEXT="${CONTEXT:-.}"

ALL_VERSIONS=(7.4 8.0 8.1 8.2 8.3 8.4)

NO_CACHE_ARG=""
if [[ "${NO_CACHE:-0}" == "1" ]]; then
  NO_CACHE_ARG="--no-cache"
fi

# --- Argumente parsen ---
ACTION="all"
VERSIONS=()

if [[ $# -gt 0 ]]; then
  case "$1" in
    build|push|all)
      ACTION="$1"
      shift
      ;;
    -h|--help)
      sed -n '3,17p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      # Kein bekanntes Subcommand → alles als Versionen behandeln
      ;;
  esac
  VERSIONS=("$@")
fi

# Ohne explizite Versionen → alle bauen
if [[ ${#VERSIONS[@]} -eq 0 ]]; then
  VERSIONS=("${ALL_VERSIONS[@]}")
fi

# --- Info ---
echo "Aktion:     ${ACTION}"
echo "Repository: ${REPO}"
echo "Dockerfile: ${DOCKERFILE}"
echo "Context:    ${CONTEXT}"
echo "Versionen:  ${VERSIONS[*]}"
echo

fail_count=0

do_build() {
  local v="$1"
  echo "=============================="
  echo ">> Baue ${REPO}${v}"
  echo "=============================="
  if docker build \
      ${NO_CACHE_ARG} \
      --build-arg "PHP_VERSION=${v}" \
      -f "${DOCKERFILE}" \
      -t "${REPO}${v}" \
      "${CONTEXT}"; then
    echo ">> Build ok: ${REPO}${v}"
    return 0
  else
    echo "!! Build fehlgeschlagen für ${v}"
    return 1
  fi
}

do_push() {
  local v="$1"
  echo ">> Push ${REPO}${v}"
  if docker push "${REPO}${v}"; then
    echo ">> Push ok: ${REPO}${v}"
    return 0
  else
    echo "!! Push fehlgeschlagen für ${v}"
    return 1
  fi
}

# --- Hauptschleife ---
for v in "${VERSIONS[@]}"; do
  case "${ACTION}" in
    build)
      do_build "$v" || ((fail_count++)) || true
      ;;
    push)
      do_push "$v" || ((fail_count++)) || true
      ;;
    all)
      if do_build "$v"; then
        do_push "$v" || ((fail_count++)) || true
      else
        ((fail_count++)) || true
      fi
      ;;
  esac
  echo
done

# --- Ergebnis ---
if (( fail_count > 0 )); then
  echo "Fertig mit ${fail_count} Fehler(n)."
  exit 1
fi

echo "Alle gewünschten Versionen erfolgreich verarbeitet."
