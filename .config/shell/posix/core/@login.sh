# shellcheck disable=SC2148
#
# Core configuration module
#

# XDG Base dir
# ==============
# References:
# - https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
# - https://wiki.archlinux.org/index.php/XDG_Base_Directory

# XDG_DATA_HOME overrides: user-specific data files
export GNUPGHOME="${XDG_DATA_HOME}/gnupg" && mkdir -p "${GNUPGHOME}"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export GOPATH="${XDG_DATA_HOME}/go"
export NPM_CONFIG_PREFIX="${XDG_DATA_HOME}/npm"
mkdir -p "${XDG_DATA_HOME}"/tig
export PYTHONUSERBASE="${XDG_DATA_HOME}/python" && mkdir -p "${PYTHONUSERBASE}"

# XDG_CONFIG_HOME overrides: user-specific configuration
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"
export ELINKS_CONFDIR="${XDG_CONFIG_HOME}/elinks"
export WGETRC="${XDG_CONFIG_HOME}/wget/config" && \
    mkdir -p "${XDG_CONFIG_HOME}"/wget

# XDG_STATE_HOME overrides: to be persisted between app restarts => logs, hist
export NODE_REPL_HISTORY="${XDG_STATE_HOME}/node/repl_history" \
    && mkdir -p "${NODE_REPL_HISTORY}"

# XDG_CACHE_HOME environment overrides.
export ICEAUTHORITY="${XDG_CACHE_HOME}/ICEauthority"
[ -f "$XDG_CACHE_HOME/Xauthority" ] \
    && export XAUTHORITY="${XDG_CACHE_HOME}/Xauthority" # X server auth cookie
export CALCHISTFILE=${XDG_CACHE_HOME}/calc_history
export PYTHONPYCACHEPREFIX="${XDG_CACHE_HOME}/python" && mkdir -p "${PYTHONPYCACHEPREFIX}"

# Paths
# =======

# Prepend user binaries to PATH to allow overriding system commands.
path_prepend "${XDG_BIN_HOME}" PATH
path_prepend "${XDG_BIN_HOME}"/usr PATH
path_prepend "${CARGO_HOME}"/bin PATH
path_prepend "${XDG_DATA_HOME}"/npm/bin PATH

# Browser
# =======

# Define the default web browser.
if [ -n "$DISPLAY" ]; then
  export BROWSER=firefox
else
  export BROWSER=elinks
fi

# Editor
# ======

# Define the default editor.
if is_callable nvim; then
  export EDITOR='nvim'
elif is_callable vim; then
  export EDITOR='vim'
elif is_callable nano; then
  export EDITOR='nano'
fi
export GIT_EDITOR="$EDITOR"
export USE_EDITOR="$EDITOR"
export VISUAL="$EDITOR"

# Pager
# =====

# Define the default pager.
export PAGER='less'

# WSL 2/1 specific settings
# ===========================

if grep -q "microsoft" /proc/version &>/dev/null; then # WSL 2
    # Required: Enables copy/paste (need to specify ip of wsl 2 VM)
    # DON'T USE WHEN RUNNING win32yank.exe
    # export DISPLAY="$(/sbin/ip route | awk '/default/ { print $3 }'):0"
    export LS_COLORS="ow=01;36;40"
    export LIBGL_ALWAYS_INDIRECT=1
    # pam_env
    export XDG_RUNTIME_DIR=/tmp/runtimedir
    export RUNLEVEL=3
    # Escape path
    export PATH=${PATH// /\\ }
    # Use explorer.exe for browser
    export BROWSER="/mnt/c/Windows/explorer.exe"
fi
