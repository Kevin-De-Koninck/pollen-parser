####################################################################################
# GLOBAL VARIABLES
####################################################################################

# Project info
MODULE="template"
REGISTRY="docker.pkg.github.com/kevin-de-koninck/python-project-template"

# Image and tag
IMAGE="${REGISTRY}/${MODULE}"
TAG="$(git describe --tags --always --dirty)"


####################################################################################
# HELPER FUNCTIONS
####################################################################################

# Print a string in red
# Arguments:
#   - $1: The string to be printed
print_red () {
  local RED="\033[0;31m"
  local NC="\033[0m"
  echo -e "${RED}${1}${NC}"
}

# Print a string in blue
# Arguments:
#   - $1: The string to be printed
print_blue () {
  local BLUE="\033[0;34m"
  local NC="\033[0m"
  echo -e "${BLUE}${1}${NC}"
}

# Print an ERROR string in red and prepend the current timestamp
# Arguments:
#   - $1: The string to be printed
print_error () {
  print_red "[$(date '+%Y-%m-%d %H:%M:%S')][ERROR] ${1}"
  exit 1
}

# Print an INFO string in blue and prepend the current timestamp
# Arguments:
#   - $1: The string to be printed
print_info () {
  print_blue "[$(date '+%Y-%m-%d %H:%M:%S')][INFO] ${1}"
}

# Parse a config.ini file to be more bash friendly.
# The ini file will be transformed where each line wil look like the following:
#     <SECTION_NAME>=<KEY>=<VALUE>
# This way, we can grep values more easily in bash, avoiding the need of specialized tools (extra dependencies)
parse_config_ini () {
  awk '/\[/{prefix=$0; next} $1{print prefix $0}' config.ini | sed -e 's/\[//' -e 's/\]/=/'
}

# Get the content of a certain section in the config.ini file
# Arguments:
#   - $1: Name of the section to be parsed
parse_section_of_config_ini () {
  local SECTION="${1}"
  while read LINE; do
    if [[ ${LINE} = "${SECTION}"* ]]; then
      echo "${LINE}" | sed -e "s/^${SECTION}=//g" -e "s/^#.*//g"
    fi
  done < <(parse_config_ini)
}

# Get the value of a certain KEY in a certain SECTION of the config.ini file
# Arguments:
#   - SECTION: The section in which the key resides
#   - KEY: The key of which the value needs to be retrieved
get_value_from_section_in_config_file () {
  local SECTION="${1}"
  local KEY="${2}"

  while read LINE; do
    if [[ ${LINE} = "${KEY}="* ]]; then
      echo "${LINE}" | cut -d '=' -f 2
    fi
  done < <(parse_section_of_config_ini "${SECTION}")
}

# Log in into the remote Docker registry using the github token file
docker_login () {
  TOKEN="$(get_value_from_section_in_config_file "META" "GITHUB_TOKEN_FILE")"
  OWNER="$(get_value_from_section_in_config_file "META" "REPO_OWNER")"

  print_info "Logging in into GitHub Docker Registry by running the following command:"
  print_info "    cat "${TOKEN}" | docker login docker.pkg.github.com -u "${OWNER}" --password-stdin"

  if ! cat "${TOKEN}" | docker login docker.pkg.github.com -u "${OWNER}" --password-stdin > /dev/null 2>&1; then
    print_error "Unable to log in into docker.pkg.github.com using the following command: cat "${TOKEN}" | docker login docker.pkg.github.com -u "${OWNER}" --password-stdin"
  fi
}

