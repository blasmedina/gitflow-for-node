#!/bin/bash

MASTER_BRANCH='master'
DEVELOP_BRANCH='develop'
PREFIX_HOTFIX='hotfix'
PREFIX_FEATURE='feature'
PREFIX_RELEASE='release'

PRERELEASE_VERSION='prerelease'
PATCH_VERSION='patch'
PREPATCH_VERSION='prepatch'
MINOR_VERSION='minor'
PREMINOR_VERSION='preminor'
MAJOR_VERSION='major'
PREMAJOR_VERSION='premajor'

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

create_version() {
    local NEWVERSION=$1
    npm version $NEWVERSION -m "Upgrade to %s"
}

create_tag() {
    local TAGNAME=$1
    git tag $TAGNAME
}

delete_tag() {
    local TAG=$1
    git tag -d $TAG
    # git push --delete origin $TAG
}

create_branch() {
    local BRANCH=$1
    git checkout -b $BRANCH
}

update_branch() {
    local BRANCH=$1
    # git pull origin $BRANCH
}

delete_branch() {
    local BRANCH=$1
    git branch -D $BRANCH
}

go() {
    local BRANCH=$1
    git checkout $BRANCH
}

publish_branch() {
    local BRANCH=$1
    # git push -u origin $BRANCH
}

# publish_tags() {
#     git push tags
# }

copy_branch() {
    local ORIGIN_BRANCH=$1
    local DESTINY_BRANCH=$2
    go $ORIGIN_BRANCH
    update_branch $ORIGIN_BRANCH
    create_branch $DESTINY_BRANCH
}

merge() {
    local ORIGIN_BRANCH=$1
    local DESTINY_BRANCH=$2
    go $DESTINY_BRANCH
    update_branch $DESTINY_BRANCH
    git merge --no-ff --no-edit $ORIGIN_BRANCH
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

ask_branch_name() {
    echo -n "${BLUE}What name will the branch have?: ${RESET}"
    read INPUT
    if [[ "$INPUT" == "" ]]; then
        echo "${YELLOW}Invalid input${RESET}"; exit 1
    fi
    BRANCH_NAME=${INPUT// /_}
}

get_current_tag() {
    local CURRENT_TAG=$(git describe)
    echo $CURRENT_TAG
}

get_current_branch() {
    local CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
    echo $CURRENT_BRANCH
}

get_current_hash_short() {
    local CURRENT_HASH=$(git rev-parse --short HEAD)
    echo $CURRENT_HASH
}

control_branch() {
    local BRANCH=$1
    if [[ "$BRANCH" == "$MASTER_BRANCH" || "$BRANCH" == "$DEVELOP_BRANCH" ]]; then
        echo "${YELLOW}Aborted process since you are in '${BRANCH}'${RESET}"
        exit 1
    fi
}

validate_branch() {
    local CURRENT_BRANCH=$1
    control_branch $CURRENT_BRANCH
    echo -n "${BLUE}Current branch '${CURRENT_BRANCH}', do you wish to continue? [yes or no]: ${RESET}"
    read YES_NO
    case $YES_NO in
        [yY] | [yY][eE][sS] ) ;;
        [nN] | [nN][oO] ) echo "Aborted process"; exit 1 ;;
        *) echo "${YELLOW}Invalid input${RESET}"; exit 1 ;;
    esac
}

testing() {
    local CURRENT_BRANCH=$(get_current_branch)
    control_branch $CURRENT_BRANCH
    local CURRENT_TAG=$(get_current_tag)
    echo "${GREEN}TAG: ${CURRENT_TAG}${RESET}"
    create_tag $CURRENT_TAG
}

start_new_feature() {
    echo "${BACKGROUND_BLUE} START FEATURE ${RESET}"
    ask_branch_name
    copy_branch $DEVELOP_BRANCH "$PREFIX_FEATURE/$BRANCH_NAME"
}

finish_feature() {
    echo "${BACKGROUND_BLUE} FINISH FEATURE ${RESET}"
    local CURRENT_BRANCH=$(get_current_branch)
    validate_branch $CURRENT_BRANCH
    merge $CURRENT_BRANCH $DEVELOP_BRANCH
    delete_branch $CURRENT_BRANCH
    publish_branch $DEVELOP_BRANCH
}

start_new_release() {
    echo "${BACKGROUND_GREEN} START RELEASE ${RESET}"
    ask_branch_name
    copy_branch $DEVELOP_BRANCH "$PREFIX_RELEASE/$BRANCH_NAME"
    testing
}

finish_release() {
    echo "${BACKGROUND_GREEN} FINISH RELEASE ${RESET}"
    local CURRENT_BRANCH=$(get_current_branch)
    validate_branch $CURRENT_BRANCH
    ask_version
    merge $CURRENT_BRANCH $MASTER_BRANCH
    create_version $VERSION
    local CURRENT_TAG=$(get_current_tag)
    merge $CURRENT_TAG $DEVELOP_BRANCH
    delete_branch $CURRENT_BRANCH
    publish_branch $MASTER_BRANCH
    publish_branch $DEVELOP_BRANCH
}

abort_release() {
    local CURRENT_BRANCH=$(get_current_branch)
    local CURRENT_TAG=$(get_current_tag)
    validate_branch $CURRENT_BRANCH
    go $DEVELOP_BRANCH
    delete_branch $CURRENT_BRANCH
    delete_tag $CURRENT_TAG
}

start_new_hotfix() {
    echo "${BACKGROUND_YELLOW} START HOTFIX ${RESET}"
    ask_branch_name
    copy_branch $MASTER_BRANCH "$PREFIX_HOTFIX/$BRANCH_NAME"
}

finish_hotfix() {
    echo "${BACKGROUND_YELLOW} FINISH HOTFIX ${RESET}"
    local CURRENT_BRANCH=$(get_current_branch)
    validate_branch $CURRENT_BRANCH
    merge $CURRENT_BRANCH $MASTER_BRANCH
    create_version $PATCH_VERSION
    local CURRENT_TAG=$(get_current_tag)
    merge $CURRENT_TAG $DEVELOP_BRANCH
    delete_branch $CURRENT_BRANCH
    publish_branch $MASTER_BRANCH
    publish_branch $DEVELOP_BRANCH
}

show_help() {
    printf "$BOLD"
    echo -e "'GitFlow for NODE' es ideal para proyecto en NODE, ya que mantiene sincronizado los TAG de git con el VERSION de package.json"
    echo -e "usage: gitflow <option>"
	printf "$RESET"
    echo -e "\nTag Testing options"
    echo -e "  ${COMMAND_TESTING}\t crear un tag para realizar prueba"
    echo -e "\nTag Feature options"
    echo -e "  ${COMMAND_START_FEATURE}\t iniciar una caracteristica"
    echo -e "  ${COMMAND_FINISH_FEATURE}\t finalizar una caracteristica"
    echo -e "\nTag Release options"
    echo -e "  ${COMMAND_START_RELEASE}\t iniciar una version"
    echo -e "  ${COMMAND_ABORT_RELEASE}\t abortar una version"
    echo -e "  ${COMMAND_FINISH_RELEASE}\t finalizar una version"
    echo -e "\nTag Hotfix options"
    echo -e "  ${COMMAND_START_HOTFIX}\t iniciar una revision"
    echo -e "  ${COMMAND_FINISH_HOTFIX}\t finalizar una revision"
}

init_config() {
    npm config set tag-version-prefix ""
    npm config set git-tag-version true
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