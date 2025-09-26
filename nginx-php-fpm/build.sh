#!/usr/bin/env bash
set -euo pipefail

# Repo kann über ENV überschrieben werden: REPO=myrepo/php ./build-push-all.sh
REPO="${REPO:-copex/nginx-php-fpm:dev-}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"
CONTEXT="${CONTEXT:-.}"

# Zu bauende PHP-Versionen
VERSIONS=(7.4 8.0 8.1 8.2 8.3 8.4)

# Optional: mit --no-cache bauen, indem NO_CACHE=1 gesetzt wird
NO_CACHE_ARG=""
if [[ "${NO_CACHE:-0}" == "1" ]]; then
  NO_CACHE_ARG="--no-cache"
fi

echo "Repository: ${REPO}"
echo "Dockerfile: ${DOCKERFILE}"
echo "Context:    ${CONTEXT}"
echo "Versionen:  ${VERSIONS[*]}"
echo

fail_count=0

for v in "${VERSIONS[@]}"; do
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
  else
    echo "!! Build fehlgeschlagen für ${v} – überspringe Push"
    ((fail_count++)) || true
    continue
  fi

#  echo ">> Push ${REPO}${v}"
#  if docker push "${REPO}${v}"; then
#    echo ">> Push ok: ${REPO}${v}"
#  else
#    echo "!! Push fehlgeschlagen für ${v}"
#    ((fail_count++)) || true
#  fi

  echo
done

if (( fail_count > 0 )); then
  echo "Fertig mit ${fail_count} Fehler(n)."
  exit 1
fi

echo "Alle gewünschten Versionen erfolgreich gebaut und gepusht."
