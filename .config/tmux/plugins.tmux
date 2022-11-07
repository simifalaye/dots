# vim: filetype=conf
#
# Configuration of tmux plugins.
# NOTE: Should be loaded last
#

# Setup
# =======

# Install tpm if not installed
TPLUG="$TMUX_DATA_DIR/plugins"
set-environment -g TMUX_PLUGIN_MANAGER_PATH $TPLUG
if "test ! -d $TPLUG/tpm" \
    "run 'git clone https://github.com/tmux-plugins/tpm $TPLUG/tpm && $TPLUG/tpm/bin/install_plugins'"

# List plugins
# Bug with alternate syntax: https://github.com/tmux-plugins/tpm/issues/57
set -g @tpm_plugins {
    tmux-plugins/tpm \
    tmux-plugins/tmux-prefix-highlight \
    tmux-plugins/tmux-resurrect \
    tmux-plugins/tmux-yank \
    Morantron/tmux-fingers
}

# Config
# ========

# tmux-yank
# -----------
set -g @yank_selection 'clipboard'
set -g @yank_selection_mouse 'clipboard'
if-shell 'command -v ${TMUX_CLIPBOARD} >/dev/null' \
    "set -g @override_copy_command '${TMUX_CLIPBOARD} > #{pane_tty}'"

# tmux-fingers
# --------------
set -g @fingers-key C-f
if-shell 'command -v ${TMUX_CLIPBOARD} >/dev/null' \
    "set -g @fingers-main-action '${TMUX_CLIPBOARD} > #{pane_tty}'"
set -g @fingers-ctrl-action  ':open:'
set -g @fingers-shift-action ':paste:'

# tmux-resurrect
# ----------------
set -g @resurrect-dir "$TMUX_DATA_DIR/resurrect"
set -g @resurrect-save 'M-s'
set -g @resurrect-restore 'M-r'
set -g @resurrect-capture-pane-contents 'on'

# Start
# =======

# Initialize the plugin manager (should be last in the config file).
run -b $TPLUG/tpm/tpm
