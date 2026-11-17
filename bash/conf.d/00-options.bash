# Ported from zsh/conf.d/00-options.zsh.
# Interactive only: the loader in ~/.bashrc runs after bash's non-interactive return.

HISTFILE=~/.bash_history
HISTSIZE=50000
HISTFILESIZE=50000

# zsh HIST_IGNORE_ALL_DUPS + HIST_IGNORE_SPACE. Omarchy sets `ignoreboth`
# (ignorespace:ignoredups); erasedups is the closer match to IGNORE_ALL_DUPS.
HISTCONTROL=ignoreboth:erasedups
# zsh EXTENDED_HISTORY — bash's timestamps come from having a format set.
HISTTIMEFORMAT='%F %T '
# Never record these.
HISTIGNORE='ls:ll:la:cd:pwd:exit:clear:history'

shopt -s histappend    # don't clobber the file other shells are writing
shopt -s cmdhist       # multi-line commands stay one history entry
shopt -s histverify    # zsh HIST_VERIFY: !! expands onto the line, doesn't run
shopt -s autocd        # zsh AUTO_CD
shopt -s checkwinsize
shopt -s globstar      # ** recursive glob
shopt -s no_empty_cmd_completion

# zsh SHARE_HISTORY: flush after every command and pull in what other shells
# wrote. Appended rather than assigned — starship (Omarchy's prompt) owns
# PROMPT_COMMAND by the time this file loads, and overwriting it kills the prompt.
_share_history() { history -a; history -n; }
if [[ ${PROMPT_COMMAND@a} == *a* ]]; then
  PROMPT_COMMAND+=(_share_history)
else
  PROMPT_COMMAND="_share_history${PROMPT_COMMAND:+$'\n'$PROMPT_COMMAND}"
fi

# No bash equivalents, noted so they aren't hunted for later:
#   HIST_REDUCE_BLANKS, AUTO_PUSHD/PUSHD_IGNORE_DUPS (and `cd` is zoxide's `zd`
#   here anyway), INTERACTIVE_COMMENTS (already default in interactive bash).
#   CORRECT was deliberately off in zsh; bash has no autocorrect at all.
