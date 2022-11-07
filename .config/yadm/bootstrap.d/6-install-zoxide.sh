#!/bin/bash
#
# Install zoxide
#
test -f ${HELPERS_D}/common.sh && source ${HELPERS_D}/common.sh

# MAIN
# ====
if is_callable zoxide; then
    exit
fi

msg "Installing zoxide"

curl -sS https://webinstall.dev/zoxide | bash

trap bye EXIT
