# shellcheck disable=SC2148
#
# Base16 configuration module
# Add base 16 colors to shell
#

BASE16_SHELL="${XDG_CONFIG_HOME}/base16-shell"

# Load repo
load_repo chriskempson/base16-shell "${BASE16_SHELL}"

# Enable to color profile helper
if [ -n "$PS1" ]; then
    [ -s "${BASE16_SHELL}/profile_helper.sh" ] &&
        eval "$("${BASE16_SHELL}/profile_helper.sh")"
fi
