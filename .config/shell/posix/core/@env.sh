# shellcheck disable=SC2148
#
# Core configuration module
#

# Env functions
# ===============

# Usage: indirect_expand PATH -> $PATH
indirect_expand () {
    env | sed -n "s/^$1=//p"
}

# Usage: path_remove /path/to/bin [PATH]
# Eg, to remove ~/bin from $PATH
#     path_remove ~/bin PATH
path_remove () {
    local IFS=':'
    local newpath
    local dir
    local var=${2:-PATH}
    # Bash has ${!var}, but this is not portable.
    for dir in $(indirect_expand "$var"); do
        IFS=''
        if [ "$dir" != "$1" ]; then
            newpath=$newpath:$dir
        fi
    done
    export "$var"="${newpath#:}"
}

# Usage: path_prepend /path/to/bin [PATH]
# Eg, to prepend ~/bin to $PATH
#     path_prepend ~/bin PATH
path_prepend () {
    [ -d "${1}" ] || return
    # if the path is already in the variable,
    # remove it so we can move it to the front
    path_remove "$1" "$2"
    local var="${2:-PATH}"
    local value
    value=$(indirect_expand "$var")
    export "${var}"="${1}${value:+:${value}}"
}

# Usage: pathappend /path/to/bin [PATH]
# Eg, to append ~/bin to $PATH
#     pathappend ~/bin PATH
path_append () {
    [ -d "${1}" ] || return
    path_remove "${1}" "${2}"
    local var=${2:-PATH}
    local value
    value=$(indirect_expand "$var")
    export "$var"="${value:+${value}:}${1}"
}

# Usage: ssource <file-1> ...
ssource () {
    for src in "$@"; do
        # shellcheck disable=SC1090
        test -r "$src" && source "$src" || echo "Failed to source: $src"
    done
}

# Usage: is_callable <cmd-1> <cmd-2> ... <cmd-n>
is_callable () {
    for cmd in "$@"; do
        command -v "$cmd" >/dev/null || return 1
    done
}

# Usage: load_repo <repo> <dest>
# Eg, to download a repo to a destination:
#     load_repo zdharma/zinit.git ~/.zinit
load_repo () {
    local repo=$1
    local dest=$2
    if [ ! -d "${dest}" ]; then
        echo "Installing ${repo}..."
        mkdir -p "${dest}"
        git clone "https://github.com/${repo}" "${dest}" ||
            >&2 echo "Failed to clone repo $repo"
    fi
}

# General
# =========

# Explicitly set XDG base dirs as they are needed later
export XDG_CACHE_HOME="${HOME}/.cache" && mkdir -p "${XDG_CACHE_HOME}"
export XDG_CONFIG_HOME="${HOME}/.config" && mkdir -p "${XDG_CONFIG_HOME}"
export XDG_DATA_HOME="${HOME}/.local/share" && mkdir -p "${XDG_DATA_HOME}"
export XDG_STATE_HOME="${HOME}/.local/state" && mkdir -p "${XDG_STATE_HOME}"
export XDG_BIN_HOME="${HOME}/.local/bin" && mkdir -p "${XDG_BIN_HOME}"

# Create files/dirs with owner r/w permissions
umask 0022
