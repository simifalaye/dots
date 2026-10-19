(( $+commands[zoxide] )) || return 0

# Configure zoxide
export _ZO_ECHO=1

# Load zsh zoxide plugin
eval "$(zoxide init zsh)"
