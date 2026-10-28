if command -v wslview >/dev/null; then
  if test -r /proc/version && grep -iq microsoft /proc/version; then
    export BROWSER="wslview"
  fi
fi

if command -v wslupath >/dev/null; then
  __userprofile=$(/mnt/c/Windows/System32/cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | head -n 1 | tr -d '\r')
  USERPROFILE="$(wslupath "$__userprofile")"
  export USERPROFILE
fi
