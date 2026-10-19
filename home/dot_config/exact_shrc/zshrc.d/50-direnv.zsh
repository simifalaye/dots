(( $+commands[direnv] )) || return 0

eval "$(direnv hook zsh)"
