# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export CUDA_HOME="/opt/cuda"
export LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"
export PATH="$HOME/.local/bin:$CUDA_HOME/bin:$PATH"

# Python environment setup
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
# if it causes errors do:
# env -u PYENV_ROOT PATH=$(echo "$PATH" | sed 's|^$HOME/.pyenv/bin:||' | sed 's|^$HOME/.pyenv/shims:||') yay -S anki-bin

export LS_COLORS='di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=1;33:cd=1;33:su=37:sg=30:tw=30:ow=34:'

alias ls='ls --color=auto'
alias ip='ip -h -c'
alias grep='grep --color=auto'
alias py='python'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias la='ls -A'
alias pacman='sudo pacman'
alias mount='sudo mount'

ai() {
  local project_dir="/home/lumi/code/ai-suite"
  local compose_file="$project_dir/docker-compose.yml"
  
  if docker compose -f "$compose_file" ps -q | xargs docker inspect -f '{{.State.Running}}' 2>/dev/null | grep -q true; then
    read -rp "Containers are running. Shut them down? [y/N] " answer
    case "$answer" in
      [yY]|[yY][eE][sS])
        docker compose -f "$compose_file" down
        ;;
      *)
        echo "Shutdown cancelled."
        ;;
    esac
  else
    docker compose -f "$compose_file" up -d
  fi
}

restart() {
  pkill -f "$1" 2>/dev/null
  (nohup "$@" >/dev/null 2>&1 &)
}

lsc() {
  if [ -f "$1" ]; then
      cat "$1"
  else
      ls "$@"
  fi
}

windows() {
  sudo efibootmgr -n 0004
  reboot
}

clean() {
  # clean cache, except huggingface models to avoid redownloads
  find ~/.cache -mindepth 1 -maxdepth 1 ! -name 'huggingface' -exec sudo rm -rf {} +
  sudo rm -rf ~/.local/share/Trash/*
  sudo rm -rf ~/.npm/_cacache
  sudo rm -rf ~/.cargo/registry
  sudo rm -rf ~/.cargo/git
  sudo rm -rf /tmp/*
  sudo rm -rf /var/tmp/*
  sudo pacman -Rns --noconfirm $(pacman -Qtdq) # remove orphaned packages
  yes | sudo pacman -Scc # remove unused package cache
  sudo journalctl --vacuum-time=7d
  docker image prune -f
  docker container prune -f
  docker builder prune -f
}

chat() {
  prompt="$*"
  token=$(<~/.open-webui-token)
  response=$(curl -s 'http://localhost:8080/api/chat/completions' \
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