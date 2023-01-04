# shellcheck disable=SC2148
#
# Fzf configuration module
#

# Load posix module first
xsh load fzf -s posix interactive || return 1

# Source fzf keybinds & completion
test -f /usr/share/doc/fzf/examples/key-bindings.bash && \
    source /usr/share/doc/fzf/examples/key-bindings.bash
test -f /usr/share/bash-completion/completions/fzf && \
    source /usr/share/bash-completion/completions/fzf
