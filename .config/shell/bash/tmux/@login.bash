#
# Tmux configuration module
#

# Abort if requirements are not met
if ! is_callable tmux; then
    return 1
fi

# XDG Dirs
export TMUX_CACHE_DIR="${XDG_CACHE_HOME}/tmux" && \
    mkdir -p ${TMUX_CACHE_DIR}
export TMUX_CONFIG_DIR="${XDG_CONFIG_HOME}/tmux"
export TMUX_DATA_DIR="${XDG_DATA_HOME}/tmux" && \
    mkdir -p ${TMUX_DATA_DIR}

# Config
export TMUX_CONFIG="${TMUX_CONFIG_DIR}/main.tmux"
export TMUX_CLIPBOARD="osc52"
