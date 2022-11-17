#
# ZLE configuration module
# Custom binds
#

# Return if requirements are not met
if [[ $TERM == 'dumb' ]]; then
  return 1
fi

# ZLE Widgets
# ===========

# Toggle process as bg and fg
function fancy-ctrl-z {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER="fg"
        zle accept-line
    else
        zle push-input
        zle clear-screen
    fi
}
zle -N fancy-ctrl-z


# Keymaps
# =======

# Toggle process bg and fg
bindkey "^z" fancy-ctrl-z
