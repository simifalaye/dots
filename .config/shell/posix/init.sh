# shellcheck disable=SC2148
#
# This file is sourced automatically by xsh if the current shell has no
# dedicated initialization file
#
# It should merely register the modules to be loaded for each runcom:
# env, login, interactive and logout.
# The order in which the modules are registered defines the order in which
# they will be loaded. Try `xsh help` for more information.
#

# Load core config
xsh module core

# Load application modules
xsh module bat interactive
xsh module fzf interactive
xsh module trash interactive:logout
