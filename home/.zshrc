# Yazi cd function
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# init_zox() {
#   # Find the git root
#   local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
#   if [[ -n "$git_root" ]]; then
#     export _ZO_DATA_DIR="$git_root/.zoxide"
#   else
#     unset _ZO_DATA_DIR
#   fi
# }

function yazi_zed() {
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git . $(git rev-parse --show-toplevel 2>/dev/null || echo .)'
    local tmp="$(mktemp -t "yazi-chooser.XXXXX")"
    yazi "$@" --chooser-file="$tmp"
    local opened_file="$(cat -- "$tmp" | head -n 1)"
    zeditor -- "$opened_file"
    rm -f -- "$tmp"
    exit
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

# Ctrl+Left / Ctrl+Right — move by word.
bindkey '\e[1;5D' backward-word
bindkey '\e[1;5C' forward-word

# Delete key
bindkey '^[[3~' delete-char

# Blinking line cursor
precmd() { echo -ne "[5 q" }
