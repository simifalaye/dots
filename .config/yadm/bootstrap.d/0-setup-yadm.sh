#!/bin/bash
#
# Yadm initialization
#
test -f ${HELPERS_D}/common.sh && source ${HELPERS_D}/common.sh

# MAIN
# ====
msg "Setting up yadm"

# Because Git submodule commands cannot operate without a work tree, they must
# be run from within $HOME (assuming this is the root of your dotfiles)
cd "$HOME"

step "Initializing submodules"
yadm submodule update --recursive --init

# permissions
step "Setting up config dir permissions"
chmod 700 ~/.cache ~/.config

# sparse checkout meta files so they aren't in the home dir
step "Sparse checkout meta files"
yadm gitconfig core.sparseCheckout true
yadm sparse-checkout set '/*' '!README.md' '!LICENSE'

trap bye EXIT
