# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH="$HOME/.local/bin:$PATH"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias py='python'
alias ai='docker compose -f "/home/lumi/code/ai-suite/docker-compose.yml" up -d'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias la='ls -A'

restart() {
  pkill -f "$1" 2>/dev/null
  (nohup "$@" >/dev/null 2>&1 &)
}

PS1='\[\e[36m\]\W\[\e[32m\]\$\[\e[0m\] '

. "$HOME/.cargo/env"

# Python environment setup
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
