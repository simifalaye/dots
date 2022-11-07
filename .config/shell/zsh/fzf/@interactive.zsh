#
# Fzf configuration module
#

# Load posix module first
xsh load fzf -s posix interactive || return 1

# Source fzf keybinds & completion
test -f /usr/share/doc/fzf/examples/key-bindings.zsh && \
    source /usr/share/doc/fzf/examples/key-bindings.zsh
test -f usr/share/doc/fzf/examples/completion.zsh && \
    source usr/share/doc/fzf/examples/completion.zsh
