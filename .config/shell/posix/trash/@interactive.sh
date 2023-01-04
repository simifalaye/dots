# shellcheck disable=SC2148
#
# Trash configuration module
#

# Abort if requirements aren't met
if ! is_callable trash; then
    return 1
fi

# Convenience aliases
alias rmm='trash'
alias rmr='trash-restore'
alias rml='trash-list'
