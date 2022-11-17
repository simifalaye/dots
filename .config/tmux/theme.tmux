# vim: filetype=conf
#
# Configuration of the tmux theme.
#

# Base16-shell
set -g allow-passthrough 1

# Status bar
set -g status           on
set -g status-position  bottom
set -g monitor-activity off
set-window-option -g status-bg colour00
set-window-option -g status-fg colour05
set-window-option -g window-status-current-format "#[fg=black,bg=blue] #I:#W "
set-window-option -g window-status-format "#[fg=brightblack] #I:#W "
set-window-option -g status-right '#{prefix_highlight} #[fg=green]#H '
set-window-option -g window-status-style fg=white,bg=default
set-window-option -g message-style fg=red,bg=default
