#!/bin/bash -e

source ./common_functions.sh

####################################################################################
# GLOBAL VARIABLES
####################################################################################
DRY_RUN=False
BASH_FLAG=False

# Docker command
DOCKER_RUN_BASE="docker run --rm -it"

####################################################################################
# HELPER FUNCTIONS
####################################################################################

help () {
  cat << EOF
./run.sh [-v VERSION] [-d] [--dryrun] [-b] [-c COMMAND] [-l]

Arguments:
    -v|--version VERSION          Overwrite the version of the to run container
    -d|--detached                 Run the container in the background (detached)
    --dryrun                      Do not actually perform the actions, just print the commands out
    -b|---bash                    Run an interactive shell inside the container
    -c|--command COMMAND          The command to be executed (will be ignore if -b is set)
    -l|--login                    Log in into the Remote Docker registry only and exit
    -h|--help                     Show this message

EOF
}

####################################################################################
# FUNCTIONS
####################################################################################

# Create a command line interface argument for a certain section.
# This will convert the data in the config.ini file into the correct port and volume mapping string
# used on the command line interface.
# Arguments:
#   - SECTION: Name of the section to be parsed (VOLUME_MAPS, PORT_MAPS)
#   - ARGS_PREFIX: CLI argument prefix in front of the maps (-v, -p)
create_cli_arg () {
  local SECTION="${1}"
  local ARGS_PREFIX="${2}"

  local ARGS=""
  while read LINE; do
    if [[ "${LINE}" != "" ]]; then
      ARGS="${ARGS} ${ARGS_PREFIX} '${LINE}'"
    fi  
  done < <(parse_section_of_config_ini "${SECTION}")

  echo "$(echo ${ARGS} | tr '=' ':')"
}

# Determine if the required docker container exists locally.
# If it does not exist locally, try to pull it from the remote.
# Else, fail the script.
check_if_container_exists () {
  if [[ "$(docker images -q ${IMAGE}:${TAG} 2> /dev/null)" == "" ]]; then
    print_info "Image '${IMAGE}:${TAG}' does not exist locally, trying to pull it from the remote repo..."
    if ! docker pull ${IMAGE}:${TAG} 2> /dev/null; then
      print_error "Image ${IMAGE}:${TAG} does not exist locally and could not be pulled from the remote repository. Please build this image first." 
    else
      print_info "Unable to download the image '${IMAGE}:${TAG}' from the remote repository. Please build this image first by running:" 
      print_info "    ./build.sh -p <dev/prod> -v ${TAG}"
    fi
  fi
}

# Run the Docker container.
run_container () {
  print_info "Running the container as follows:"
  print_info "  ${DOCKER_RUN_BASE} ${IMAGE}:${TAG} ${COMMAND}"
  if [[ "${DRY_RUN}" == "False" ]]; then
    eval ${DOCKER_RUN_BASE} ${IMAGE}:${TAG} ${COMMAND}
  fi
}

####################################################################################
# MAIN
####################################################################################
# Docker command
VOLUME_ARG="$(create_cli_arg "VOLUME_MAPS" "-v")"
PORT_ARG="$(create_cli_arg "PORT_MAPS" "-p")"
if [[ "${VOLUME_ARG}" != "" ]]; then DOCKER_RUN_BASE="${DOCKER_RUN_BASE} ${VOLUME_ARG}"; fi
if [[ "${PORT_ARG}" != "" ]]; then DOCKER_RUN_BASE="${DOCKER_RUN_BASE} ${PORT_ARG}"; fi

# Parse the arguments
while [[ $# -gt 0 ]]; do
  key="${1}"
  case ${key} in
    -c|--command)
      COMMAND="${2}"
      shift
      shift
      ;;
    -b|--bash)
      BASH_FLAG=True
      DOCKER_RUN_BASE="${DOCKER_RUN_BASE} --entrypoint ''"
      shift
      ;;
    -d|--detached)
      DOCKER_RUN_BASE="${DOCKER_RUN_BASE} -d"
      shift
      ;;
    --dryrun)
      DRY_RUN=True
      shift
      ;;
    -v|--version)
      TAG="${2}"
      shift # past argument
      shift # past value
      ;;
    -l|--login)
      docker_login
      exit 0
      ;;
    -h|--help)
      help
      exit 0
      ;;
    *)    # unknown option
      echo "[ERROR] Unknown action: ${1}"
      exit 1
      ;;
  esac
done

# Overwrite the command with 'bash' to start an interactive shell if -'b is provided
if [[ "${BASH_FLAG}" == "True" ]]; then
  COMMAND="bash"
fi

# Check if the container exists
check_if_container_exists

# Run the container (dev or prod, depending on the version tag)
run_container

exit 0

