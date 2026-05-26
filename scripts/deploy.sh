#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

cd liferay/workspace
./gradlew deploy

LIFERAY_CONTAINER="$(sudo docker ps --filter "name=liferay" --format '{{.Names}}' | head -n 1)"

if [ -n "$LIFERAY_CONTAINER" ]; then
	echo "Suivi des logs du conteneur Liferay: $LIFERAY_CONTAINER"
	sudo docker logs --follow "$LIFERAY_CONTAINER"
else
	echo "Aucun conteneur Liferay en cours d'execution trouve."
	echo "Demarrez les conteneurs puis relancez ce script pour suivre les logs."
fi



