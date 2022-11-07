#
# Zoxide configuration module
#

# Abort if requirements aren't met
if ! is_callable zoxide; then
    return 1
fi

# Config
export _ZO_ECHO=1

# Startup zoxide
eval "$(zoxide init bash)"
