# Ported from zsh/conf.d/10-env.zsh.

export EDITOR="nvim"
export VISUAL="nvim"
export SUDO_EDITOR="nvim"   # Omarchy defaults this to omarchy-launch-editor

# NVIM_APPNAME is deliberately NOT set here. On the Mac the config lives at
# ~/.config/lazyvim; on this machine it is merged into Omarchy's ~/.config/nvim,
# so Mason data stays in ~/.local/share/nvim and Omarchy's theme hot-reload and
# OSC52 clipboard keep working.

export LANG="en_US.UTF-8"
# LC_ALL deliberately not set: it overrides every LC_* category, so a later
# LC_TIME/LC_COLLATE tweak would be silently ignored. LANG alone is enough.

export ERL_AFLAGS="-kernel shell_history enabled"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
export GOPATH="$HOME/go-workspace"
export CLAUDE_CODE_NO_FLICKER=1

# MANPAGER is already set identically by Omarchy's default/bash/envs — not
# repeated here. Dropped from the Mac config: LDFLAGS/CPPFLAGS pointing at
# /opt/homebrew/opt/llvm.

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons {}'"
