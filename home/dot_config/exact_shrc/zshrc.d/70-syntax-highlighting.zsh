#
# NOTE: This module should be loaded after all ZLE widgets have been defined.
# Namely, after the 'input' module.
#

#
# Plugin: zsh-syntax-highlighting
#

# Abort if requirements are not met
(( $+functions[znap] )) || return 0
[[ -o interactive ]] || return 0

# Set highlighters
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

#Load plugin
znap source zsh-users/zsh-syntax-highlighting
