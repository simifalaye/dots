#
# This file is sourced automatically by xsh if the current shell is `zsh`
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
xsh module -s bash base16 interactive
xsh module -s bash exa interactive
xsh module -s bash ripgrep interactive
xsh module -s bash tmux interactive:login
xsh module zoxide interactive

# Load plugin manager
# NOTE: ZLE and completion will be setup here
xsh module zim interactive

# Load extra modules that provide and bind ZLE widgets
xsh module fzf interactive
xsh module zle interactive
