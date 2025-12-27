# Yazi cd function
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# Zoxide
eval "$(zoxide init --cmd=cd zsh)"

# Git prompt
autoload -Uz vcs_info
precmd() { vcs_info }
setopt prompt_subst
zstyle ':vcs_info:git:*' formats ' %F{magenta}(%b)%f'
PROMPT='%F{yellow}%1~%f${vcs_info_msg_0_} ➜ '

bindkey -e

# Ctrl+Backspace to delete word backward
bindkey '^H' backward-kill-word

# Ctrl+Delete to delete word forward (your existing one)
bindkey '^[[3;5~' kill-word
