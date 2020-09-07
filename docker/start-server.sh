#!/bin/bash

SAVE_DIR=${FACTORIO_ROOT}/saves
SAVE_PATH=${SAVE_DIR}/${SAVE_FILE}
SERVER_EXECUTABLE=${FACTORIO_ROOT}/bin/x64/factorio

_terminate() {
	echo "Caught SIGTERM signal"
	kill -s INT "$child" 2>/dev/null
}

trap _term SIGTERM

if [ -z "${SAVE_FILE}" ]; then
	# Save file is unset; just try to load the latest
	SAVE_PARAMETERS="--start-server-load-latest"
elif [ -f "${SAVE_PATH}" ]; then
	# Save file exists - file portion of server executable loads the file
	SAVE_PARAMETERS="--start-server ${SAVE_PATH}.zip"
else
	# Save file doesn't exist - create new save
	${SERVER_EXECUTABLE} --create ${SAVE_PATH}.zip
	SAVE_PARAMETERS="--start-server ${SAVE_PATH}.zip"
fi

${SERVER_EXECUTABLE} \
	--rcon-port 25575 \
	--rcon-password factorio \
	${SAVE_PARAMETERS}

child=$!

wait "$child"
