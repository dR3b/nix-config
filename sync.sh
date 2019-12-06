#! /usr/bin/env bash
set -o pipefail -o noclobber -o nounset

NIXOS_PATH="/etc/nixos"
HOME_MANAGER_PATH="$HOME/.config/nixpkgs"
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

SYSTEM_SYNC=0
HOME_SYNC=0

NIXOS_BOOT=0
NIXOS_SWITCH=1

UPGRADE=0

DRY_RUN=0

function cprint() {
    if [ "$#" -lt 2 ]; then
        printf "Broken usage of cprint\n"
        exit 1
    fi
    local color="$1"
    local msg="${*:2}"
    local reset
    reset="$(tput sgr0)"

    [ -z ${NO_COLOR+1} ] || color=""
    [ -z ${NO_COLOR+1} ] || reset=""

    printf "%s%s%s\n" "$color" "$msg" "$reset"
}

function error() {
    local red
    red="$(tput setaf 1)"
    cprint "$red" "$@"
    exit 1
}

function warn() {
    local yellow
    yellow="$(tput setaf 3)"
    cprint "$yellow" "$@"
}

function ok() {
    local green
    green="$(tput setaf 2)"
    cprint "$green" "$@"
}

function debug() {
    local blue
    blue="$(tput setaf 4)"
    cprint "$blue" "$@"
}

function fix_perms() {
    [ "$#" -eq 2 ] || error "fix_perms USER PATH"
    local user="$1"
    local path="$2"

    local fix_dirs="find \"$path\" -type d -exec chmod 0755 {} \;"
    local fix_files="find \"$path\" -type f -exec chmod 0644 {} \;"

    sudo runuser -l "$user" -c "$fix_dirs"
    sudo runuser -l "$user" -c "$fix_files"
}

function sync_dir() {
    [ "$#" -eq 3 ] || error "sync_dir USER SOURCE DEST"
    local user="$1"
    local src="$2"
    local dest="$3"

    # Fix paths (damn rsync)
    if [ "${src:(-1)}" != "/" ]; then
        # add trailing / to src
        src="$src/"
    fi
    if [ "${dest:(-1)}" != "/" ]; then
        # add trailing / to dest
        dest="$dest/"
    fi

    # -i, --itemize-changes       output a change-summary for all updates
    # -r, --recursive             recurse into directories
    # -h, --human-readable        output numbers in a human-readable format
    # -l, --links                 copy symlinks as symlinks
    # -t, --times                 preserve modification times
    local rsync_cmd="rsync -irhlt --delete \"$src\" \"$dest\""
    [ $DRY_RUN == 0 ] && sudo runuser -l "$user" -c "$rsync_cmd"
    [ $DRY_RUN == 0 ] && fix_perms "$user" "$dest"
}

function sync_module() {
    [ "$#" -eq 3 ] || error "sync_module USER ROOT_PATH DIRS"
    local user="$1"
    local root_path="$2"
    local dirs=("${!3}")

    for dir in "${dirs[@]}"; do
        sync_dir "$user" "$SCRIPT_PATH/$dir" "$root_path/$dir"
    done
}

function check_module() {
    [ "$#" -eq 3 ] || error "check_module ROOT_PATH FILES DIRS"
    local root_path="$1"
    local files=("${!2}")
    local dirs=("${!3}")

    for rel_path in "${files[@]}"; do
        local abs_path="$root_path/$rel_path"
        [ -f "${abs_path}" ] || warn "${abs_path} missing!"
    done

    for rel_path in "${dirs[@]}"; do
        local abs_path="$root_path/$rel_path"
        [ -d "${abs_path}" ] || warn "${abs_path} missing!"
    done
}

function sync_system() {
    [ "$#" -eq 0 ] || error "sync_system"
    local files=("configuration.nix" "hardware-configuration.nix")
    local dirs=("system" "share")
    sync_module "root" "$NIXOS_PATH" dirs[@]
    check_module "$NIXOS_PATH" files[@] dirs[@]
}

function sync_home() {
    [ "$#" -eq 0 ] || error "sync_home"
    local files=("config.nix" "home.nix")
    local dirs=("home" "share")
    sync_module "$USER" "$HOME_MANAGER_PATH" dirs[@]
    check_module "$HOME_MANAGER_PATH" files[@] dirs[@]
}

function check_sudo() {
    [ "$#" -eq 0 ] || error "check_sudo"
    [ -x "$(command -v sudo)" ] || error "Sudo not available."
    [[ "$USER" == *"not allowed to run sudo"* ]] &&
        error "$USER does not have sudo privileges"
}

function rebuild_system() {
    [ "$#" -eq 0 ] || error "rebuild_system"
    local op=""
    if [ $NIXOS_SWITCH = 1 ]; then
        op="switch"
    elif [ $NIXOS_BOOT = 1 ]; then
        op="boot"
    else
        error "rebuild_system ENOOP"
    fi
    [ $DRY_RUN == 0 ] && [ $UPGRADE == 1 ] && sudo nix-channel --update
    [ $DRY_RUN == 0 ] && sudo nixos-rebuild "$op"
}

function rebuild_home() {
    [ "$#" -eq 0 ] || error "rebuild_home"
    [ $DRY_RUN == 0 ] && [ $UPGRADE == 1 ] && nix-channel --update
    [ $DRY_RUN == 0 ] && home-manager switch
}

function check_getopt() {
    [ "$#" -eq 0 ] || error "check_getopt"
    ! getopt --test >/dev/null
    if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
        error '"getopt --test" failed in this environment.'
    fi
}

function parse_opts() {
    local options="sbuSHAd"
    local longopts="switch,boot,upgrade,system,home,all,dry-run"
    local parsed
    ! parsed=$(getopt --options="$options" --longoptions="$longopts" --name "$0" -- "$@")
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        error "Wrong arguments passed"
    fi
    eval set -- "$parsed"
    while true; do
        case "$1" in
        -s | --switch)
            NIXOS_SWITCH=1
            NIXOS_BOOT=0
            shift
            ;;
        -b | --boot)
            NIXOS_SWITCH=0
            NIXOS_BOOT=1
            shift
            ;;
        -u | --upgrade)
            UPGRADE=1
            shift
            ;;
        -S | --system)
            SYSTEM_SYNC=1
            shift
            ;;
        -H | --home)
            HOME_SYNC=1
            shift
            ;;
        -A | --all)
            SYSTEM_SYNC=1
            HOME_SYNC=1
            shift
            ;;
        -d | --dry-run)
            DRY_RUN=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            error "Invalid argument"
            ;;
        esac
    done
}

function main() {
    [ "$(id -u)" != 0 ] || error "Run this as a your user, not root."
    check_getopt
    parse_opts "$@"
    if [ $SYSTEM_SYNC = 1 ]; then
        check_sudo
        sync_system
        rebuild_system
        ok "System OK"
    fi
    if [ $HOME_SYNC == 1 ]; then
        sync_home
        rebuild_home
        ok "Home OK"
    fi
}

main "$@"
