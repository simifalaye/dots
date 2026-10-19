if ! test -x "${HOME}"/.local/bin/mise; then
  return
fi

eval "$(${HOME}/.local/bin/mise activate bash)"
