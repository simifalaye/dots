if ! command -v trash >/dev/null; then
  return
fi

alias rmm='trash'
alias rmr='trash-restore'
alias rml='trash-list'
