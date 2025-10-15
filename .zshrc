export EDITOR=nvim
alias ll="lsd -la"
alias ls="lsd"

if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi

# source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
export ZELLIJ_AUTO_ATTACH=true
export ZELLIJ_AUTO_EXIT=true
if [[ "$ALACZELL" = "true" ]]; then
    eval "$(zellij setup --generate-auto-start zsh)"
fi
eval "$(zoxide init --cmd=cd zsh)"

autoload -Uz vcs_info
precmd() { vcs_info }
setopt prompt_subst
zstyle ':vcs_info:git:*' formats ' %F{magenta}(%b)%f'
PROMPT='%F{yellow}%1~%f${vcs_info_msg_0_} ➜ '

bindkey '^[[3;5~' kill-word
