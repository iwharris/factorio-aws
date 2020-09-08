#!/bin/bash
# set -x

# sanity check
if [ -z "${FACTORIO_ROOT}" ]; then
	echo "Error: \$FACTORIO_ROOT must be set"
	exit 1
fi

CONFIG_DIR=${FACTORIO_ROOT}/config
DATA_DIR=${FACTORIO_ROOT}/data
SAVE_DIR=${FACTORIO_ROOT}/saves
SAVE_PATH=${SAVE_DIR}/${SAVE_FILE}
SERVER_EXECUTABLE=${FACTORIO_ROOT}/bin/x64/factorio

# Populates the config directory from templates if files are missing
load_configuration () {
	CONFIG_PARAMETERS=""

	files=( "map-gen-settings" "map-settings" "server-settings" )

	# Copy config file templates if they aren't already provided
	for name in "${files[@]}"
	do
		config_file_path="${CONFIG_DIR}/${name}.json"
		if [ ! -f "${config_file_path}" ]; then
			echo "${config_file_path} wasn't provided; using defaults..."
			config_template_path="${DATA_DIR}/${file}.example.json"
			cp "${config_template_path}" "${config_file_path}"
		fi
		CONFIG_PARAMETERS="${CONFIG_PARAMETERS} --${name} ${config_file_path}"
	done

	list_files=( "server-whitelist" "server-banlist" "server-adminlist" )
	for name in "${list_files[@]}"
	do
		list_file_path="${CONFIG_DIR}/${name}.json"
		if [ ! -f "${list_file_path}" ]; then
			echo "Creating an empty ${name} file..."
			echo "[]" > ${list_file_path}
		fi
		
		list_length=`jq -r '. | length' ${list_file_path}`
		# Server will complain if empty list files are provided on command-line
		if [ "${list_length}" -gt 0 ]; then
			# Special case; non-empty whitelist must be accompanied with --user-server-whitelist
			if [ "${name}" == server-whitelist ]; then
				CONFIG_PARAMETERS="${CONFIG_PARAMETERS} --use-server-whitelist"
			fi
			CONFIG_PARAMETERS="${CONFIG_PARAMETERS} --${name} ${list_file_path}"
		fi
	done
}

# Builds arg string with map settings files if they exist
# - map-gen-settings.json
# - map-settings.json
get_map_config_string() {
    local map_configs=( "map-gen-settings" "map-settings" )
	MAP_CONFIG=""

	for name in "${map_configs[@]}"
		do
		path="${CONFIG_DIR}/${name}.json"
		if [ -f "${path}" ]; then
			MAP_CONFIG="${MAP_CONFIG} --${name} ${path}"
		fi
	done

    return $MAP_CONFIG
}

# Creates a new save, using the map generation settings from config
create_map() {
	get_map_config_string

	echo "Creating map (${SAVE_PATH})..."

	${SERVER_EXECUTABLE} \
		${MAP_CONFIG} \
		--create ${SAVE_PATH}.zip
}

generate_map_preview() {
    get_map_config_string
	# TODO
}

prepare_save() {
	if [ -z "${SAVE_FILE}" ]; then
		# Save file is unset; just try to load the latest
		SAVE_PARAMETERS="--start-server-load-latest"
	elif [ -f "${SAVE_PATH}" ]; then
		# Save file exists - file portion of server executable loads the file
		SAVE_PARAMETERS="--start-server ${SAVE_PATH}.zip"
	else
		# Save file doesn't exist - create new save
		create_map
		SAVE_PARAMETERS="--start-server ${SAVE_PATH}.zip"
	fi
}


PORT_PARAMETERS="--port ${FACTORIO_PORT} --rcon-port ${RCON_PORT} --rcon-password ${RCON_PASSWORD}"
load_configuration
prepare_save

exec ${SERVER_EXECUTABLE} \
	${PORT_PARAMETERS} \
	${SAVE_PARAMETERS} \
	${CONFIG_PARAMETERS}
