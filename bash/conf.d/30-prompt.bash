# Use the same Atomic theme as the macOS dotfiles.
# Omarchy initializes Starship first; detach its hooks before activating Posh.
# OMP_THEME can select another local theme, or "starship" to keep Starship.
if [[ ${OMP_THEME:-atomic} != starship ]] && command -v oh-my-posh >/dev/null 2>&1; then
  _omp_config="$HOME/.config/oh-my-posh/${OMP_THEME:-atomic}.omp.json"
  if [[ -f $_omp_config ]]; then
    _omp_init="$(oh-my-posh init bash --config "$_omp_config")"
    if [[ -n $_omp_init ]]; then
      # Keep history and other prompt callbacks while removing Starship.
      _omp_commands=()
      for _omp_command in "${PROMPT_COMMAND[@]}"; do
        _omp_command=${_omp_command//starship_precmd/${STARSHIP_PROMPT_COMMAND:-}}
        [[ -n $_omp_command ]] && _omp_commands+=("$_omp_command")
      done
      PROMPT_COMMAND=("${_omp_commands[@]}")
      [[ ${PS0:-} == *starship_preexec_ps0* ]] && unset PS0
      unset STARSHIP_START_TIME STARSHIP_PREEXEC_READY
      eval "$_omp_init"
      # Capture the command's exit status before history and other callbacks.
      _omp_commands=(_omp_hook)
      for _omp_command in "${PROMPT_COMMAND[@]}"; do
        [[ $_omp_command != _omp_hook ]] && _omp_commands+=("$_omp_command")
      done
      PROMPT_COMMAND=("${_omp_commands[@]}")
    fi
  else
    printf 'prompt: theme does not exist: %s\n' "$_omp_config" >&2
  fi
  unset _omp_config _omp_init _omp_commands _omp_command
fi
