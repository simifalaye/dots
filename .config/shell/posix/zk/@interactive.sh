#
# ZK notes configuration module
#

# Abort if requirements aren't met
if ! is_callable zk; then
    return 1
fi

# Set notebook dir
export ZK_NOTEBOOK_DIR="${HOME}/notes"
