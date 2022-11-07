#
# Core configuration module for zsh
# Reference: https://zsh.sourceforge.io/Doc/Release/Options.html
#

# Options
# =======

# History
# -------

HISTFILE="${ZCACHEDIR}/zhistory"
# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

# Input/output
# ------------

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -e

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# Aliases
# =========

alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g L="| less"
alias -g M="| most"
alias -g HP='--help'
alias -g VR="--version"
alias -g LL="2>&1 | less"
alias -g CA="2>&1 | cat -A"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"

# Local config
# ============
# IMPORTANT: MUST BE AT THE END TO OVERRIDE

if test -f "${HOME}/.zshrc.local"; then
    source "${HOME}/.zshrc.local"
fi
