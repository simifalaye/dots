#!/bin/bash
# vim: filetype=bash

# Globals
# =========
# shellcheck disable=SC2034
BASH_COMP_DIR="/usr/share/bash-completion/completions"
ZSH_COMP_DIR="/usr/local/share/zsh/site-functions"
MAN_DIR="/usr/local/share/man/man1/"
USER_CONF_FILE="${HOME}/.local/share/yadm/user.conf"

# Msg helpers
# =============
# Standardize messages for all user visible scripts

# Color helpers
cn=$'\e[0m'; black=$'\e[1;30m'; red=$'\e[1;31m'; green=$'\e[1;32m'
yellow=$'\e[1;33m'; blue=$'\e[1;34m'; magenta=$'\e[1;35m'; cyan=$'\e[1;36m'
white=$'\e[1;37m'

msg()
{
    echo ""
    echo "${cyan}--------------------------------------------------${cn}"
    echo "${cyan}-->${white} ${1} ${cn}"
    echo ""
}
bye()
{
    echo ""
    echo "${cyan}-->${white} End of $0 ${cn}"
    echo "${cyan}--------------------------------------------------${cn}"
}
step() { echo -e "${green} :: ${cn}${1}..."; }
note() { echo -e "    ${1}"; }
err() {  echo -e "    ${red}ERROR${cn}: ${1}"; }

# Functions
# ===========

# Read value of key from user conf file
# @param key: key to read
# @return string value
user_conf_read()
{
    key="${1}"
    if [ ! -f "${USER_CONF_FILE}" ]; then
        echo ""
        return 1
    fi

    while read -r line; do declare "$line"; done <"${USER_CONF_FILE}"
    eval val=\$"$key"
    echo "${val}"
}

# Write value of key to user conf file
# @param key: key to write to
# @param val: value
# return 0 if successful
user_conf_write()
{
    key="${1}"
    val="${2}"
    if [ ! -f "${USER_CONF_FILE}" ]; then
        mkdir -p "${USER_CONF_FILE%/*}" && touch "${USER_CONF_FILE}"
    fi

    if grep -q "${key}=" "${USER_CONF_FILE}"; then
        sed -i '/'"${key}"'=/ s/=.*/='"${val}"'/' "${USER_CONF_FILE}"
    else
        echo "${key}=${val}" >> "${USER_CONF_FILE}"
    fi
}

# Prompt user input
# @param msg: question to user
# @return 0 if they respoded 'y' or 'Y'
prompt_yes()
{
    msg=${1}
    read -p "${msg}" -n 1 -r
    echo    # (optional) move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 1
    fi
    return 0
}

# Determine if string is denotes true ([yY], [yY]es, true)
# @param {1}: the string
# @return 0 if true
is_true() {
    if [[ "${1,,}" =~ ^[Yy]$ ]] \
        || [[ "${1,,}" =~ ^[Yy]es$ ]] \
        || [[ "${1,,}" =~ "true" ]]; then
        return 0
    fi
    return 1
}

# Determine if file or command is callable
# @param vararg: list of commands/files
# @return 0 if true
is_callable()
{
    for cmd in "$@"; do
        command -v "$cmd" >/dev/null || return 1
    done
}

# Determine the latest release version of a github repo
# @param repo: repo shortname (<user>/<repo-name>)
# @return outputs latest version name or returns 1
get_latest_github()
{
    repo="${1}"
    cmd=""
    url="https://api.github.com/repos/${repo}/releases/latest"
    wget -q -O - "${url}" | grep -Po '(?<="tag_name": ").*(?=")'
}

# Read user conf once and set
Y_EPHEMERAL=$(user_conf_read ephemeral)
Y_HEADLESS=$(user_conf_read headless)
[ -z "${Y_EPHEMERAL}" ] && Y_EPHEMERAL=n
[ -z "${Y_HEADLESS}" ] && Y_HEADLESS=y
