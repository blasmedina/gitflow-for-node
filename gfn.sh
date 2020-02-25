#!/bin/bash

MASTER_BRANCH='master'
DEVELOP_BRANCH='develop'
PREFIX_HOTFIX='hotfix'
PREFIX_FEATURE='feature'
PREFIX_RELEASE='release'

PATCH_VERSION='patch'
MINOR_VERSION='minor'
MAJOR_VERSION='major'

COMMAND_COMMIT='-c'
COMMAND_INIT='-i'
COMMAND_HELP='-h'
COMMAND_TESTING='-t'
COMMAND_START_FEATURE='-sf'
COMMAND_FINISH_FEATURE='-ff'
COMMAND_START_RELEASE='-sr'
COMMAND_FINISH_RELEASE='-fr'
COMMAND_ABORT_RELEASE='-ar'
COMMAND_START_HOTFIX='-sh'
COMMAND_FINISH_HOTFIX='-fh'

setup_color() {
	# Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RESET=$(printf '\033[0m')
		BOLD=$(printf '\033[1m')
    UNDERLINE=$(printf '\033[4m')
    REVERSED=$(printf '\033[7m')
    BLACK=$(printf '\033[30m')
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
    MAGENTA=$(printf '\033[35m')
    CYAN=$(printf '\033[36m')
    WHITE=$(printf '\033[37m')
    BACKGROUND_BLACK=$(printf '\033[37;40m')
    BACKGROUND_RED=$(printf '\033[30;41m')
    BACKGROUND_GREEN=$(printf '\033[30;42m')
    BACKGROUND_YELLOW=$(printf '\033[30;43m')
    BACKGROUND_BLUE=$(printf '\033[30;44m')
    BACKGROUND_MAGENTA=$(printf '\033[30;45m')
    BACKGROUND_CYAN=$(printf '\033[30;46m')
    BACKGROUND_WHITE=$(printf '\033[30;47m')
	else
		RESET=""
		BOLD=""
    UNDERLINE=""
    REVERSED=""
    BLACK=""
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
    MAGENTA=""
    CYAN=""
    WHITE=""
    BACKGROUND_BLACK=""
    BACKGROUND_RED=""
    BACKGROUND_GREEN=""
    BACKGROUND_YELLOW=""
    BACKGROUND_BLUE=""
    BACKGROUND_MAGENTA=""
    BACKGROUND_CYAN=""
    BACKGROUND_WHITE=""
	fi
}

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

error() {
	echo ${RED}"Error: $@"${RESET} >&2
}

get_current_tag() {
  echo $(git describe)
}

get_current_branch() {
  echo $(git symbolic-ref --short HEAD)
}

get_current_version() {
  echo $(node --print "require('./package.json').version")
}

delete_branch() {
    local BRANCH=$1
    echo " ${BACKGROUND_YELLOW} DELETE BRANCH DISABLE: '${BRANCH}' ${RESET} "
    # git branch -d $BRANCH
    # git push origin --delete $BRANCH
}

publish_branch() {
    local BRANCH=$1
    echo " ${BACKGROUND_YELLOW} PUBLIC BRANCH DISABLE: '${BRANCH}' ${RESET} "
    # git push origin $BRANCH
}

publish_tags() {
    echo " ${BACKGROUND_YELLOW} PUBLIC TAGS DISABLE ${RESET} "
    # git push origin --tags
}

ask_branch_name() {
  echo -n "${BLUE}What name will the branch have?: ${RESET}"
  read INPUT
  if [[ "$INPUT" == "" ]]; then
      echo "${YELLOW}Invalid input${RESET}"; exit 1
  fi
  BRANCH_NAME=${INPUT// /_}
}

ask_version() {
  echo -n "${BLUE}What is the release level? [major or minor]: ${RESET}"
  read INPUT
  case $INPUT in
      [mM][aA][jJ][oO][rR] ) VERSION=$MAJOR_VERSION ;;
      [mM][iI][nN][oO][rR] ) VERSION=$MINOR_VERSION ;;
      *) echo "Invalid input"; exit 1 ;;
  esac
}

create_tag() {
  local TAGNAME=$1
  git tag --sign $TAGNAME --message "v${TAGNAME}"
}

go() {
  local BRANCH=$1
  git checkout $BRANCH
}

create_branch() {
  local NEW_BRANCH=$1
  git checkout -b $NEW_BRANCH
}

clone_branch() {
  local ORIGIN_BRANCH=$1
  local NEW_BRANCH=$2
  go $ORIGIN_BRANCH
  create_branch $NEW_BRANCH
}

init_config() {
  npm config set tag-version-prefix ""
  npm config set git-tag-version true
}

show_help() {
  echo -e "usage: ${0} <option>\n"
  printf "$MAGENTA"
  echo -e "Tag Testing options"
  printf "$RESET"
  echo -e "  ${COMMAND_TESTING}\t crear un tag para realizar prueba"
  printf "$BLUE"
  echo -e "Tag Feature options"
  printf "$RESET"
  echo -e "  ${COMMAND_START_FEATURE}\t iniciar una caracteristica"
  echo -e "  ${COMMAND_FINISH_FEATURE}\t finalizar una caracteristica"
  printf "$GREEN"
  echo -e "Tag Release options"
  printf "$RESET"
  echo -e "  ${COMMAND_START_RELEASE}\t iniciar una version"
  echo -e "  ${COMMAND_ABORT_RELEASE}\t abortar una version"
  echo -e "  ${COMMAND_FINISH_RELEASE}\t finalizar una version"
  printf "$YELLOW"
  echo -e "Tag Hotfix options"
  printf "$RESET"
  echo -e "  ${COMMAND_START_HOTFIX}\t iniciar una revision"
  echo -e "  ${COMMAND_FINISH_HOTFIX}\t finalizar una revision"
}

testing() {
  local CURRENT_TAG=$(get_current_tag)
  echo "${GREEN}TAG: ${CURRENT_TAG}${RESET}"
  create_tag $CURRENT_TAG
}

start_new_feature() {
  echo "${BACKGROUND_BLUE} START FEATURE ${RESET}"
  ask_branch_name && clone_branch $DEVELOP_BRANCH "$PREFIX_FEATURE/$BRANCH_NAME"
}

finish_feature() {
  echo "${BACKGROUND_BLUE} FINISH FEATURE ${RESET}"
  local CURRENT_BRANCH=$(get_current_branch) && merge $CURRENT_BRANCH $DEVELOP_BRANCH && fast_commit
  publish_branch $DEVELOP_BRANCH
  delete_branch $CURRENT_BRANCH
}

start_new_release() {
  echo "${BACKGROUND_GREEN} START RELEASE ${RESET}"
  ask_branch_name && clone_branch $DEVELOP_BRANCH "$PREFIX_RELEASE/$BRANCH_NAME"
  testing
}

finish_release() {
  echo "${BACKGROUND_GREEN} FINISH RELEASE ${RESET}"
  local CURRENT_BRANCH=$(get_current_branch) && ask_version && merge $CURRENT_BRANCH $MASTER_BRANCH && update_pkg_version $VERSION
  local CURRENT_VERSION=$(get_current_version) && fast_commit && create_tag $CURRENT_VERSION
  local CURRENT_TAG=$(get_current_tag) && merge $CURRENT_TAG $DEVELOP_BRANCH && fast_commit
  publish_branch $MASTER_BRANCH
  publish_branch $DEVELOP_BRANCH
  delete_branch $CURRENT_BRANCH
}

start_new_hotfix() {
  echo "${BACKGROUND_YELLOW} START HOTFIX ${RESET}"
  ask_branch_name && clone_branch $MASTER_BRANCH "$PREFIX_HOTFIX/$BRANCH_NAME"
}

finish_hotfix() {
  echo "${BACKGROUND_YELLOW} FINISH HOTFIX ${RESET}"
  local CURRENT_BRANCH=$(get_current_branch) && merge $CURRENT_BRANCH $MASTER_BRANCH && update_pkg_version $PATCH_VERSION
  local CURRENT_VERSION=$(get_current_version) && fast_commit && create_tag $CURRENT_VERSION
  local CURRENT_TAG=$(get_current_tag) && merge $CURRENT_TAG $DEVELOP_BRANCH && fast_commit
  publish_branch $MASTER_BRANCH
  publish_branch $DEVELOP_BRANCH
  delete_branch $CURRENT_BRANCH
}

fast_commit() {
  git add --all && git commit --gpg-sign --no-edit
}

commit() {
  git add --all && git commit --gpg-sign
}

merge () {
  local ORIGIN=$1
  local DESTINATION=$2
  git checkout $DESTINATION && git merge --no-ff --no-edit --gpg-sign --no-commit $ORIGIN
}

update_pkg_version() {
  local NEW_VERSION=$1
  npm version --no-git-tag-version $NEW_VERSION
}

init() {
  npm init --yes
  local CURRENT_VERSION=$(get_current_version)
  git init
  git add --all
  git commit --gpg-sign=$KEY_ID_SIGN --message "Init commit"
  create_tag $CURRENT_VERSION
  create_branch $DEVELOP_BRANCH
}

main () {
  setup_color
  command_exists npm || {
    error "npm is not installed"
    exit 1
	}
  if [ $# -eq 1 ]; then
    init_config
    case "$1" in
      $COMMAND_COMMIT ) commit ;;
      $COMMAND_INIT ) init ;;
      $COMMAND_HELP ) show_help ;;
      $COMMAND_TESTING ) testing ;;
      $COMMAND_START_FEATURE ) start_new_feature ;;
      $COMMAND_FINISH_FEATURE ) finish_feature ;;
      $COMMAND_START_RELEASE ) start_new_release ;;
      $COMMAND_FINISH_RELEASE ) finish_release ;;
      $COMMAND_ABORT_RELEASE ) abort_release ;;
      $COMMAND_START_HOTFIX ) start_new_hotfix ;;
      $COMMAND_FINISH_HOTFIX ) finish_hotfix ;;
      *) echo "${YELLOW}Invalid command${RESET}" ;;
    esac
  else
    echo "No arguments supplied"
  fi
}

main "$@"