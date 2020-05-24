#!/bin/bash -e

source ./common_functions.sh

####################################################################################
# GLOBAL VARIABLES
####################################################################################
# Version string
VERSION="0.0.0"

# Other vars
SKIP_TESTS=False
PUSH_TO_REGISTRY=False
CLEAN=False
PROJECT="UNDEFINED"

####################################################################################
# HELPER FUNCTIONS
####################################################################################

help () {
  cat << EOF
./build.sh -p PROJECT [-v VERSION] [-u] [-s] [-c]

Required arguments:
    -p|--project PROJECT           The project to be build (dev/prod)

Optional arguments:
    -v|--version VERSION           Overwrite the version of the prod container
    -u|--upload                    Push the build to the GitHub registry
    -s|--skip-tests                Build the project but disable the tests
    -c|--clean                     Remove all local docker images of our builds
    -h|--help                      Show this message

EOF
}

####################################################################################
# FUNCTIONS
####################################################################################

# Parse the config.ini file and prepare the Dockerfile statement.
# Arguments:
#   - WHAT: The ini file section (ENVIRONMENT_VARS, PORT_MAPS)
#   - CMD_PREFIX: The prefix for the generated list (ENV, EXPOSE)
# Sample output:
#   - ENV A=1 B=2
#   - EXPOSE 1000 1001
create_dockerfile_command () {
  local WHAT="${1}"
  local CMD_PREFIX="${2}"

  local CMD=""
  while read LINE; do
    if [[ "${LINE}" != "" ]]; then
      if [[ "${WHAT}" == "ENVIRONMENT_VARS" ]]; then
        CMD="${CMD} ${LINE}"
      else
        CMD="${CMD} $(echo "${LINE}" | cut -d '=' -f 2)"
      fi
    fi
  done < <(parse_section_of_config_ini "${WHAT}")
  if [[ "${CMD}" != "" ]]; then
    CMD="${CMD_PREFIX}${CMD}"
  fi
  echo "${CMD}"
}

# Build function that builds (and if required) runs all tests for a certain project.
# Arguments:
#   - BUILD_PROJECT: Project to be build (dev/prod)
build (){
  local BUILD_PROJECT="${1}"

  # Prepare the dynamic Dockerfile commands based on the config.ini file
  local ENV_CMD="$(create_dockerfile_command "ENVIRONMENT_VARS" "ENV")"
  local EXPOSE_CMD="$(create_dockerfile_command "PORT_MAPS" "EXPOSE")"

  print_info "Building ${PROJECT} image with labels:"
  print_info "    Name:     ${MODULE}"
  print_info "    Version:  ${VERSION}"

  if [[ "${SKIP_TESTS}" == "True" ]]; then
    print_info "Skipping tests during build..."
    sed -e "s|{NAME}|${MODULE}|g" \
        -e "s|{VERSION}|${VERSION}|g" \
        -e "s|#ENVIRONMENT_VARS|${ENV_CMD}|g" \
        -e "s|#EXPOSED_PORTS|${EXPOSE_CMD}|g" \
        -e '/#START_TESTS_MARKER/,/#END_TESTS_MARKER/d' \
        Dockerfile.${BUILD_PROJECT} | docker build -t ${IMAGE}:${VERSION} -f- .
  else
    sed -e "s|{NAME}|${MODULE}|g" \
        -e "s|{VERSION}|${VERSION}|g" \
        -e "s|#ENVIRONMENT_VARS|${ENV_CMD}|g" \
        -e "s|#EXPOSED_PORTS|${EXPOSE_CMD}|g" \
        Dockerfile.${BUILD_PROJECT} | docker build -t ${IMAGE}:${VERSION} -f- .
  fi

  # Push the image to the registry if required.
  if [[ "${PUSH_TO_REGISTRY}" == "True" ]]; then
    echo
    print_info "Pushing image to GitHub Docker Registry..."
    docker push ${IMAGE}:${VERSION}
  fi
}

####################################################################################
# MAIN
####################################################################################

# Parse the arguments
while [[ $# -gt 0 ]]; do
  key="${1}"
  case ${key} in
    -p|--project)
      PROJECT="${2}"
      shift # past argument
      shift # past value
      ;;
    -s|--skip-tests)
      SKIP_TESTS=True
      shift # past argument
      ;;
    -u|--upload)
      PUSH_TO_REGISTRY=True
      shift # past argument
      ;;
    -c|--clean)
      CLEAN=True
      shift # past argument
      ;;
    -v|--version)
      VERSION="${2}"
      shift # past argument
      shift # past value
      ;;
    -h|--help)
      help
      exit 0
      ;;
    *)    # unknown option
      echo "[ERROR] Unknown argument: ${1}"
      exit 1
      ;;
  esac
done

# Check for required arguments
if [ -z ${PROJECT+x} ]; then
  if [[ "${CLEAN}" == "False" ]]; then
    echo "[ERROR] Argument '-p|--project' is required but missing..."
    echo
    help
    exit 1
  fi
fi

# Build the project
case "${PROJECT}" in
  prod)
    build "prod"
    ;;
  dev)
    VERSION="${TAG}"
    build "dev"
    ;;
  # Default value, case item will activate when cleaning only
  UNDEFINED)
    ;;
  *)
    echo "[ERROR] Project '${PROJECT}' is not a supported value."
    exit 1
esac

# Clean the local Docker registry if required
if [[ "${CLEAN}" == "True" ]]; then
  echo
  print_info "Cleaning the local Docker registry by running the following command:"
  print_info "  docker system prune -f --filter "label=name=${MODULE}""
  docker system prune -f --filter "label=name=${MODULE}"
fi

exit 0

