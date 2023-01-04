# shellcheck disable=SC2148
#
# This file is sourced automatically by xsh if the current shell is `bash`
#
# It should merely register the modules to be loaded for each runcom:
# env, login, interactive and logout.
# The order in which the modules are registered defines the order in which
# they will be loaded. Try `xsh help` for more information.
#

# Load core config
xsh module core -s posix
xsh module core

# Load application modules that have no requirements
xsh module -s posix bat interactive
xsh module -s posix trash interactive:logout
xsh module -s posix zk interactive
xsh module base16 interactive
xsh module exa interactive
xsh module fzf interactive
xsh module ripgrep interactive
xsh module tmux interactive:login
xsh module zoxide interactive
