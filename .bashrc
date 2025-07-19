# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH="$HOME/.local/bin:$PATH"
export LS_COLORS='di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=1;33:cd=1;33:su=37:sg=30:tw=30:ow=34:'

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

chat() {
  prompt="$*"
  token=$(<~/.open-webui-token)
  response=$(curl -s 'https://lumiey.uk/api/chat/completions' \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json" \
    -d @- <<EOF | jq -r '.choices[0].message.content // "Error: " + (.error.message // "Unknown error")'
{
  "model": "llama-4-scout-17b-16e-instruct",
  "messages": [
    {
      "role": "system",
      "content": "Provide only short, direct answers. Be concise and straight to the point."
    },
    {
      "role": "user",
      "content": $(printf '%s' "$prompt" | jq -R .)
    }
  ]
}
EOF
)
  echo "$response" | glow -
}

PS1='\[\e[36m\]\W\[\e[32m\]\$\[\e[0m\] '

. "$HOME/.cargo/env"

# Python environment setup
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
# this might cause errors, to avoid do:
# env -u PYENV_ROOT PATH=$(echo "$PATH" | sed 's|^$HOME/.pyenv/bin:||' | sed 's|^$HOME/.pyenv/shims:||') yay -S anki-bin