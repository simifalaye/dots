# vim: filetype=conf
#
# Main tmux configuration file.
#
# This configuration expects that the following environments variables are available:
# Required:
# - TMUX_CONFIG - The path to the tmux config file
# - TMUX_CONFIG_DIR - The path to the parent directory to source other configuration files.
# Optional:
# - TMUX_CLIPBOARD - The command to copy a buffer to the system clipboard.
# - TMUX_CACHE_DIR - The path to the directory where to store tmux cache.
# - TMUX_DATA_DIR - The path to the directory to where to store tmux data.
#

# Setup default env
run 'export TMUX_CLIPBOARD=${TMUX_CLIPBOARD:-xclip -selection clipboard}'
run 'export TMUX_CACHE_DIR=${TMUX_CACHE_DIR:-~/.cache}'
run 'export TMUX_DATA_DIR=${TMUX_DATA_DIR:-~/.local/share}'
run "tmux setenv -g TMUX_VERSION $(tmux -V | cut -d' ' -f2)"

# Server options
# ================

# Set the correct TERM.
set-option -g default-terminal "tmux-256color"

# Enable true color.
set-option -ga terminal-overrides ",*256col*:Tc"

# Time to wait after escape is input
set -sg escape-time 10

# Focus events enabled
set-option -g focus-events on

# Path to the history file for tmux commands.
set -s history-file "$TMUX_DATA_DIR/history"

# Global session/window options
# ===============================

# Set shell
set-option -g default-shell "${SHELL}"

# Mouse support
set-option -g mouse on

# Start window/pane indexes from 1 instead of 0.
set -g base-index 1
set -g pane-base-index 1

# When a window is closed, automatically renumber the other windows in numerical order.
set -g renumber-windows on

# Time in milliseconds the status messages are shown.
set -g display-time 2000
# Time in millisecond the pane numbers are shown and allowed to be selected.
set -g display-panes-time 1000

# Maximum number of lines held in window/pane history.
set -g history-limit 100000

# Time in milliseconds to allow multiple commands to be entered without the prefix-key.
set -g repeat-time 500

# Activity bell and whistles
set -g monitor-activity on

# Notify of activity/silence in other windows only.
set -g activity-action other
set -g silence-action other
# Disable all bells.
set -g bell-action none

# Send a bell on activity.
set -g visual-activity off
# Display a status message instead of a bell on silence.
set -g visual-silence on

# Useful for multi-monitor setup
set-window-option -g aggressive-resize on

# Word separators for copy-mode.
set -g word-separators " ._-~=+:;?!@&*()[]{}|<>/"

# Renew environment variables
set -g update-environment \
  "DISPLAY\
  SSH_ASKPASS\
  SSH_AUTH_SOCK\
  SSH_AGENT_PID\
  SSH_CONNECTION\
  SSH_TTY\
  WINDOWID\
  XAUTHORITY"

# Configuration Modules
# =======================

source "$TMUX_CONFIG_DIR/theme.tmux"
source "$TMUX_CONFIG_DIR/bindings.tmux"
source "$TMUX_CONFIG_DIR/plugins.tmux"
