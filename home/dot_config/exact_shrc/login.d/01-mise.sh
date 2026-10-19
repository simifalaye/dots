MISE_PATH="${HOME}/.local/share/mise/shims"

[[ "${PATH}" =~ ${MISE_PATH} ]] || \
  export PATH="${MISE_PATH}:${PATH}"
