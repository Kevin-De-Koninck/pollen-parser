
####################################################################################
# GLOBAL VARIABLES
####################################################################################

# Project info
MODULE="boilerplate"
REGISTRY="docker.pkg.github.com/kevin-de-koninck/python-project-boilerplate"

# Image and tag
IMAGE="${REGISTRY}/${MODULE}"
TAG="$(git describe --tags --always --dirty)"


####################################################################################
# HELPER FUNCTIONS
####################################################################################

print_red () {
  local RED="\033[0;31m"
  local NC="\033[0m"
  echo -e "${RED}${1}${NC}"
}

print_blue () {
  local BLUE="\033[0;34m"
  local NC="\033[0m"
  echo -e "${BLUE}${1}${NC}"
}

print_error () {
  print_red "[$(date '+%Y-%m-%d %H:%M:%S')][ERROR] ${1}"
  exit 1
}

print_info () {
  print_blue "[$(date '+%Y-%m-%d %H:%M:%S')][INFO] ${1}"
}

is_mac () {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    return 0
  else
    return 1
  fi
}

parse_config_ini () {
  awk '/\[/{prefix=$0; next} $1{print prefix $0}' config.ini | sed -e 's/\[//' -e 's/\]/=/'
}

parse_section_of_config_ini () {
  local SECTION="${1}"
  while read LINE; do
    if [[ ${LINE} = "${SECTION}"* ]]; then
      echo "${LINE}" | sed -e "s/^${SECTION}=//g" -e "s/^#.*//g"
    fi
  done < <(parse_config_ini)
}

get_value_from_section_in_config_file () {
  local SECTION="${1}"
  local KEY="${2}"

  while read LINE; do
    if [[ ${LINE} = "${KEY}="* ]]; then
      echo "${LINE}" | cut -d '=' -f 2
    fi
  done < <(parse_section_of_config_ini "${SECTION}")
}

docker_login () {
  print_info "Logging in into GitHub Docker Registry."
  TOKEN="$(get_value_from_section_in_config_file "META" "GITHUB_TOKEN_FILE")"
  OWNER="$(get_value_from_section_in_config_file "META" "REPO_OWNER")"

  if ! cat "${TOKEN}" | docker login docker.pkg.github.com -u "${OWNER}" --password-stdin > /dev/null 2>&1; then
    print_error "Unable to log in into docker.pkg.github.com using the following command: cat "${TOKEN}" | docker login docker.pkg.github.com -u "${OWNER}" --password-stdin"
  fi
}

