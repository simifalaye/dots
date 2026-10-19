emit_osc_prompts() {
  printf '\033]133;A\007'
  printf '\033]7;file://%s%s\007' "${HOST:-$(hostname -s)}" "${PWD}"
}

if ! (( ${+precmd_functions[(r)emit_osc_prompts]} )); then
  precmd_functions+=(emit_osc_prompts)
fi
