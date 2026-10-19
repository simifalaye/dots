if ! command -v wslview >/dev/null; then
  return
fi

if test -r /proc/version && grep -iq microsoft /proc/version; then
  export BROWSER="wslview"
fi
