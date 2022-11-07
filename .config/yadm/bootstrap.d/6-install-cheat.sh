#!/bin/bash
#
# Install cheat.sh
#
test -f ${HELPERS_D}/common.sh && source ${HELPERS_D}/common.sh

# MAIN
# ====
if is_callable cht.sh; then
    exit
fi

msg "Installing cheat"

curl "https://cht.sh/:cht.sh" | sudo tee /usr/local/bin/cht.sh &&
    sudo chmod +x /usr/local/bin/cht.sh

trap bye EXIT
