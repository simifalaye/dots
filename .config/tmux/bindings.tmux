# vim: filetype=conf
#
# Configuration of tmux key bindings.
#

# Verify tmux version
# (Need 3.2+ for adding notes '-N' to binds)

# Root
# ======

# Enable mouse support by default.
set -g mouse on

# Prevent status line scrolling from switching windows.
unbind -T root 'WheelUpStatus'
unbind -T root 'WheelDownStatus'

# Remove S-Up copy-mode
unbind -T root 'S-Up'

# Fix mouse wheel for applications using legacy scroll.
# See https://github.com/tmux/tmux/issues/1320#issuecomment-381952082.
bind -T root 'WheelUpPane' {
  if -Ft= "#{||:#{pane_in_mode},#{mouse_any_flag}}" {
    send -Mt=
  } {
    if -Ft= '#{alternate_on}' {
      send -t= -N 3 Up
    } {
      copy-mode -et=
    }
  }
}
bind -T root 'WheelDownPane' {
  if -Ft= "#{||:#{pane_in_mode},#{mouse_any_flag}}" {
    send -Mt=
  } {
    if -Ft= '#{alternate_on}' {
      send -t= -N 3 Down
    } {
      send -Mt=
    }
  }
}

# Paste the most recent buffer on middle click.
bind -T root 'MouseDown2Pane' {
  select-pane -t=
  if -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" {
    send -M
  } {
    paste-buffer -p
  }
}

bind -T root 'DoubleClick1Pane' {
  select-pane -t=
  if -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" {
    send -M
  } {
    copy-mode -H; send -X select-word; run -d0.3; send -X copy-pipe-and-cancel
  }
}
bind -T root 'TripleClick1Pane' {
  select-pane -t=
  if -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" {
    send -M
  } {
    copy-mode -H; send -X select-line; run -d0.3; send -X copy-pipe-and-cancel
  }
}

# Zoom/unzoom the selected pane.
bind -T root 'C-DoubleClick1Pane' resize-pane -Zt=

# Prefix
# ========

# Remove all default key bindings.
unbind -a -T prefix

# Set the prefix key to C-Space.
unbind 'C-b'
set -g prefix 'C-Space'
bind 'C-Space' send-prefix

# Configuration management.
bind -N 'Reload the tmux configuration' 'C-r' source-file ${TMUX_CONFIG} \; \
    display-message "${TMUX_CONFIG} reloaded"

# Client/Session operations.
bind -N 'Detach the current client' 'd' detach-client
bind -N 'Detach other clients' 'D' if -F '#{session_many_attached}' \
    'confirm-before -p "Detach other clients? (y/n)" "detach -a"' \
    'display "Session has only 1 client attached"'
bind -N 'Suspend the current client' 'Z' suspend-client
bind -N 'Create a new session' 'C' command-prompt "new-session -s '%%'"
bind -N 'Rename the current session' 'R' command-prompt -I "#S" "rename-session -- '%%'"
bind -N 'Quit the current session' 'Q' confirm-before -p "kill-session #S? (y/n)" kill-session
bind -N 'Merge session w/ another' 'C-u' command-prompt -p "Session to merge with: " \
    "run-shell 'yes | head -n #{session_windows} | xargs -I {} -n 1 tmux movew -t %%'"

# Client/Session selection.
bind -N 'Select a session interactively' 's' choose-tree -Zs
bind -N 'Select the next session' -r 'Tab' switch-client -n
bind -N 'Select the previous session' -r 'BTab' switch-client -p

# Window operations.
bind -N 'Create a new window' 'c' new-window -c "#{pane_current_path}"
bind -N 'Rename the current window' 'r' command-prompt -I "#W" "rename-window -- '%%'"
bind -N 'Kill the current window' 'X' kill-window
bind -N 'Kill other windows' 'C-x' confirm-before -p \
    "kill other windows? (y/n)" "kill-window -a"
bind -N 'Respawn the current window' '$' confirm-before -p \
    "respawn-window #W? (y/n)" "respawn-window -k"
bind -N 'Move the current window the the left' -r '<' swap-window -d -t -1
bind -N 'Move the current window the the right' -r '>' swap-window -d -t +1

# Window selection.
bind -N 'Select a window interactively' 'w' choose-tree -Zw
bind -N 'Select the next window' -r 'C-]' next-window
bind -N 'Select the previous window' -r 'C-[' previous-window
bind -N 'Select the last window' 'Space' last-window
bind -N 'Select window 1' '1' select-window -t :=1
bind -N 'Select window 2' '2' select-window -t :=2
bind -N 'Select window 3' '3' select-window -t :=3
bind -N 'Select window 4' '4' select-window -t :=4
bind -N 'Select window 5' '5' select-window -t :=5
bind -N 'Select window 6' '6' select-window -t :=6
bind -N 'Select window 7' '7' select-window -t :=7
bind -N 'Select window 8' '8' select-window -t :=8
bind -N 'Select window 9' '9' select-window -t :=9
bind -N 'Select window 10' '0' select-window -t :=10

# Window splitting.
bind -N 'Split the current window horizontally' '|' split-window -h -c "#{pane_current_path}"
bind -N 'Split the current window vertically' '_' split-window -v -c "#{pane_current_path}"

# Window layouts.
bind -N 'Select the next window layout' -r '}' next-layout
bind -N 'Select the previous window layout' -r '{' previous-layout
bind -N 'Select the even-horizontal layout' 'M-1' select-layout even-horizontal
bind -N 'Select the even-vertical layout' 'M-2' select-layout even-vertical
bind -N 'Select the main-horizontal layout' 'M-3' select-layout main-horizontal
bind -N 'Select the main-vertical layout' 'M-4' select-layout main-vertical
bind -N 'Select the tiled layout' 'M-5' select-layout tiled
bind -N 'Spread the panes out evenly' 'M-e' select-layout -E

# Pane operations.
bind -N 'Mark the current pane' 'm' select-pane -m
bind -N 'Clear the marked pane' 'M' select-pane -M
bind -N 'Break the current pane into a new window' 'C-b' break-pane
bind -N 'Join the marked pane with the current pane' 'C-j' join-pane
bind -N 'Swap the current pane with the pane above' -r 'o' swap-pane -U
bind -N 'Swap the current pane with the pane below' -r 'O' swap-pane -D
bind -N 'Rotate the panes upward in the current window' -r 'C-o' rotate-window -U
bind -N 'Rotate the panes downward in the current window' -r 'M-o' rotate-window -D
bind -N 'Kill the current pane' 'x' kill-pane
bind -N 'Respawn the current pane' '#' confirm-before -p \
    "respawn-pane #P? (y/n)" "respawn-pane -k"
bind -N 'Zoom the current pane' 'z' resize-pane -Z

# Pane Selection
bind -N 'List and select a pane by index' 'p' display-panes
bind -N 'Select the next pane' -r ']' select-pane -t :.+
bind -N 'Select the previous pane' -r '[' select-pane -t :.-

# Buffer selection.
bind -N 'Paste the most recent buffer'  'v' paste-buffer -p
bind -N 'Select a buffer interactively' 'b' choose-buffer -Z {
  run -b "tmux show-buffer -b '%%' | $TMUX_CLIPBOARD"
}

# Enter backward search mode directly.
bind -N 'Search backward for a regular expression' '/' copy-mode \; send '?'

# Keymap information.
bind -N 'List key bindings' '?' display-popup -w80 -h90% -E "tmux list-keys -N | $PAGER"
bind -N 'Describe a key binding' '.' command-prompt -k -p "(key)" "list-keys -1N \"%%%\""

# Status line commands.
bind -N 'Prompt for a command' ':' command-prompt
bind -N 'Show status line messages' ';' show-messages

# Activity monitoring.
bind -N 'Toggle activity monitoring for the current window' '+' {
  set monitor-activity
  display 'monitor-activity #{?monitor-activity,on,off}'
}

# Silence monitoring.
bind -N 'Toggle silence monitoring for the current window' '=' {
  if -F '#{monitor-silence}' {
    set monitor-silence 0
    display 'monitor-silence off'
  } {
    command-prompt -p "(silence interval)" -I "2" {
      set monitor-silence '%%'
      display 'monitor-silence #{monitor-silence}'
    }
  }
}

# Pane synchronization.
bind -N 'Toggle pane synchronization in the current window' 'y' {
  set synchronize-panes
  display 'synchronize-panes #{?synchronize-panes,on,off}'
}

# Enter copy mode.
bind -N 'Enter copy mode' 'Enter' copy-mode

# Tmux.nvim
# ===========
# https://github.com/aserowy/tmux.nvim

# Cycle-free pane navigation
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind -n 'C-h' if-shell "$is_vim" 'send-keys C-h' { if -F '#{pane_at_left}' '' 'select-pane -L' }
bind -n 'C-j' if-shell "$is_vim" 'send-keys C-j' { if -F '#{pane_at_bottom}' '' 'select-pane -D' }
bind -n 'C-k' if-shell "$is_vim" 'send-keys C-k' { if -F '#{pane_at_top}' '' 'select-pane -U' }
bind -n 'C-l' if-shell "$is_vim" 'send-keys C-l' { if -F '#{pane_at_right}' '' 'select-pane -R' }
bind -T copy-mode-vi 'C-h' if -F '#{pane_at_left}' '' 'select-pane -L'
bind -T copy-mode-vi 'C-j' if -F '#{pane_at_bottom}' '' 'select-pane -D'
bind -T copy-mode-vi 'C-k' if -F '#{pane_at_top}' '' 'select-pane -U'
bind -T copy-mode-vi 'C-l' if -F '#{pane_at_right}' '' 'select-pane -R'

# Pane resizing
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind -n 'M-h' if-shell "$is_vim" 'send-keys M-h' 'resize-pane -L 1'
bind -n 'M-j' if-shell "$is_vim" 'send-keys M-j' 'resize-pane -D 1'
bind -n 'M-k' if-shell "$is_vim" 'send-keys M-k' 'resize-pane -U 1'
bind -n 'M-l' if-shell "$is_vim" 'send-keys M-l' 'resize-pane -R 1'
bind-key -T copy-mode-vi M-h resize-pane -L 1
bind-key -T copy-mode-vi M-j resize-pane -D 1
bind-key -T copy-mode-vi M-k resize-pane -U 1
bind-key -T copy-mode-vi M-l resize-pane -R 1
