#!/bin/bash
#
# General cleanup of a new/updated system
#
# shellcheck disable=SC1091
test -f "${HELPERS_D}"/common.sh && source "${HELPERS_D}"/common.sh

# Files and directories that should be always removed
# MUST be absolute paths
REMOVE=(
    "${HOME}"/.gitconfig
    "${HOME}"/.gitignore
    "${HOME}"/.lesshst
    "${HOME}"/.lesskey
    "${HOME}"/.npmrc
    "${HOME}"/.tmux.conf
    "${HOME}"/.ripgreprc
    "${HOME}"/.wget-hsts
    "${HOME}"/.viminfo
    "${HOME}"/.tig_history
    "${HOME}"/.calc_history
    "${HOME}"/.python_history
)

# DIRECTORIES that should exactly match git (remove extra local files)
# MUST be relative to $HOME
EXACT=(
    # Nvim
    .config/nvim/lua
    .config/nvim/lua/conf
    .config/nvim/lua/conf/core
    .config/nvim/lua/conf/plugins
    .config/nvim/lua/conf/plugins/lsp
    .config/nvim/lua/conf/utils
    .config/shell/bash
    .config/shell/posix
    .config/shell/zsh
)

# MAIN
# ====
msg "Cleaning up"

step "Removing redundant pre-installed files"
rm -rf "${REMOVE[@]}"

step "Cleaning up git folders"
# Must be in home dir
cd "${HOME}" || exit
yadm_files=$(yadm ls-files)
for dir in "${EXACT[@]}"; do
    [ -d "${dir}" ] || continue
    for obj in "${dir}"/*; do
        if ! echo "${yadm_files}" | grep -q "${obj}"; then
            note "Removing untracked file '${obj}' from '${dir}'"
            if is_callable trash; then
                trash "${obj}"
            else
                rm -rf "${obj}"
            fi
        fi
    done
done

trap bye EXIT
