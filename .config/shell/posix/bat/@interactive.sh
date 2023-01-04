# shellcheck disable=SC2148
#
# Bat configuration module
#

# Abort if requirements are not met.
if ! is_callable bat; then
  return 1
fi

export BAT_PAGER='less -F'
alias cat="bat -p"
