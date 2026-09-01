_omp_config="$HOME/.config/oh-my-posh/atomic.omp.json"
if (( $+commands[oh-my-posh] )) && [[ -f "$_omp_config" ]]; then
  _omp_cache="$HOME/.cache/oh-my-posh-init.zsh"
  if [[ ! -f "$_omp_cache" || "$_omp_config" -nt "$_omp_cache" || "${commands[oh-my-posh]}" -nt "$_omp_cache" ]]; then
    oh-my-posh init zsh --config "$_omp_config" > "$_omp_cache"
  fi
  source "$_omp_cache"
fi
unset _omp_config _omp_cache
