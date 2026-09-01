HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt EXTENDED_HISTORY
setopt HIST_VERIFY
setopt HIST_FIND_NO_DUPS

setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
# CORRECT is deliberately off: it flags valid per-project binaries and git
# subcommands ("correct 'rails' to 'rail'?").
