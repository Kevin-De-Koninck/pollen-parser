#!/bin/bash
set -eu

source ./common_functions.sh

# Original names
OLD_MODULE_NAME_LOWER_CASE='pollenparser'
OLD_MODULE_NAME_CAPITALIZED='Pollenparser'
OLD_REPO_NAME="pollen-parser"
OLD_REPO_OWNER="kevin-de-koninck"
OLD_GITHUB_TOKEN_FILE="/Users/kevin/GH_TOKEN.txt"

# New names
MODULE_NAME="$(get_value_from_section_in_config_file "META" "MODULE_NAME")"
REPO_NAME="$(basename $(git rev-parse --show-toplevel))"
REPO_OWNER="$(get_value_from_section_in_config_file "META" "REPO_OWNER")"
GITHUB_TOKEN_FILE="$(get_value_from_section_in_config_file "META" "GITHUB_TOKEN_FILE")"

# The main functionality

print_info "Renaming variables and files..."

MODULE_LOWERCASE="$(echo "${MODULE_NAME}" | awk '{print tolower($0)}')"
MODULE_CAPITALIZED="$(tr '[:lower:]' '[:upper:]' <<< ${MODULE_LOWERCASE:0:1})${MODULE_LOWERCASE:1}"

git grep -l "${OLD_MODULE_NAME_LOWER_CASE}" | xargs sed -i '' -e "s/${OLD_MODULE_NAME_LOWER_CASE}/${MODULE_LOWERCASE}/g"
git grep -l "${OLD_MODULE_NAME_CAPITALIZED}" | xargs sed -i '' -e "s/${OLD_MODULE_NAME_CAPITALIZED}/${MODULE_CAPITALIZED}/g"
git grep -l "${OLD_REPO_NAME}" | xargs sed -i '' -e "s/${OLD_REPO_NAME}/${REPO_NAME}/g"
git grep -l "${OLD_REPO_OWNER}" | xargs sed -i '' -e "s/${OLD_REPO_OWNER}/${REPO_OWNER}/g"
git grep -l "${OLD_GITHUB_TOKEN_FILE}" | xargs sed -i '' -e "s|${OLD_GITHUB_TOKEN_FILE}|${GITHUB_TOKEN_FILE}|g"

git mv "${OLD_MODULE_NAME_LOWER_CASE}" "${MODULE_LOWERCASE}"

print_info "Testing if everything works by building the development container and running the integrated test stage..."
if ! ./build.sh --project dev --clean; then
  print_error "Building and testing the development container failed. Please investigate and fix manually..."
fi

print_info "Adding all changes to a new commit..."
git add -u 
git commit -m "Initialize project"

print_info "Setting a new tag in the repository..."
git tag -a v0.0.0 -m "First draft for Github action 'push'"

print_info "All changes are inside the local commit 'Initialize project'. Use 'git push' to push these changes. This will trigger the github action."
print_info "Tag v0.0.0 has been set. Use 'git push origin --tags' to push the tag. This will trigger a github action that builds and pushes the production container image to the remote Docker registry."
print_info "You can now safely remove this script. Have fun!"
exit 0

