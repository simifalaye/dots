#!/bin/bash
#
# Setup a the shell environment
#
test -f ${HELPERS_D}/common.sh && source ${HELPERS_D}/common.sh

# MAIN
# ====
msg "Setting up shell env"

cur_shell=$(cat /etc/passwd | grep $USER | awk -F ":" '{print $NF}')
tar_shell=$(is_callable zsh && echo zsh || echo bash)
if [ ! -x "${cur_shell}" ] || [[ ${cur_shell} != *"${tar_shell}"* ]]; then
    step "Changing the login shell to ${tar_shell}"
    sudo chsh $USER --shell="$(which ${tar_shell})"
fi

xsh_d="${HOME}/.config/xsh"
if [ ! -f ${xsh_d}/xsh.sh ]; then
    step "Installing xsh"
    ver=$(get_latest_github "sgleizes/xsh")
    if [ -n "${ver}" ]; then
        mkdir -p ${xsh_d}
        wget -qO- https://github.com/sgleizes/xsh/archive/refs/tags/${ver}.tar.gz | \
            tar xvz -C ${xsh_d} --strip-components 1
    fi
fi
if ! is_callable xsh && [ -r ${xsh_d}/xsh.sh ]; then
    step "Bootstrapping xsh($xsh_d)"
    source ${xsh_d}/xsh.sh
    xsh bootstrap --shells posix:bash:zsh
fi

trap bye EXIT
