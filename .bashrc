# If not running interactively, don't do anything
[[ $- != *i* ]] && return

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

alias mount-ram='sudo mount -t tmpfs -o size=24G,mode=1777,noatime tmpfs /mnt/ram'
alias umount-ram='sudo umount /mnt/ram'

disk-bench() {
  target="."

  mkdir -p "$target/fio" > /dev/null 2>&1

  cleanup() {
      rm -rf "$target/fio"
  }
  trap cleanup INT TERM EXIT

  GREEN="\033[1;32m"
  BLUE="\033[1;34m"
  YELLOW="\033[1;33m"
  RED="\033[1;31m"
  BRIGHT="\033[1m"
  DIM="\033[2m"
  NC="\033[0m"

  printf "${YELLOW}Test             MB/s   IOPS    µs${NC}\n"
  echo            "----             ----   ----    --"

  run_fio() {
    local name=$1
    local rw=$2
    local bs=$3
    local iodepth=$4
    local numjobs=$5
    local color=$6

    size=512
    qsize=$(($size / $iodepth))

    local json=$(fio --name="$name" \
        --ioengine=libaio \
        --rw="$rw" \
        --bs="$bs" \
        --numjobs="$numjobs" \
        --iodepth="$iodepth" \
        --size=${size}m \
        --group_reporting \
        --direct=1 \
        --time_based \
        --runtime=4 \
        --directory="$target/fio" \
        --output-format=json)

    local mbps iops lat
    if [[ $rw == *read* ]]; then
        mbps=$(echo "$json" | jq ".jobs[0].read.bw_bytes / 1e6" | awk '{printf "%.0f", $1}')
        iops=$(echo "$json" | jq ".jobs[0].read.iops" | awk '{printf "%.0f", $1}')
        lat=$(echo "$json" | jq ".jobs[0].read.lat_ns.mean / 1000" | awk '{printf "%.0f", $1}')
    else
        mbps=$(echo "$json" | jq ".jobs[0].write.bw_bytes / 1e6" | awk '{printf "%.0f", $1}')
        iops=$(echo "$json" | jq ".jobs[0].write.iops" | awk '{printf "%.0f", $1}')
        lat=$(echo "$json" | jq ".jobs[0].write.lat_ns.mean / 1000" | awk '{printf "%.0f", $1}')
    fi

    gb=$((mbps / 1000))
    mb=$((mbps % 1000))
    if (( gb > 0 )); then
        mbps_fmt=$(printf "${gb}${DIM}$(printf "%03d" $mb)${NC}${color}")
    else
        mbps_fmt=$(printf "${mb}${DIM}${NC}${color}")
    fi

    k_iops=$((iops / 1000))
    iops=$((iops % 1000))
    if (( k_iops > 0 )); then
        iops_fmt=$(printf "${k_iops}${DIM}$(printf "%03d" $iops)${NC}${color}")
    else
        iops_fmt=$(printf "${iops}${DIM}${NC}${color}")
    fi
    
    printf "${color}%-16s %-21s %-22s %-6s${NC}\n" "$name" "$mbps_fmt" "$iops_fmt" "$lat"
 
    rm -rf "$target/fio"/*
  }

  run_fio "R Seq1M   Q8T1" read 1m 8 1 $GREEN
  run_fio "R Seq128K Q32T1" read 128k 32 1 $GREEN
  run_fio "R Rnd4K   Q32T16" randread 4k 32 16 $YELLOW
  run_fio "R Rnd4K   Q1T1" randread 4k 1 1 $YELLOW
  
  run_fio "W Seq1M   Q8T1" write 1m 8 1 $BLUE
  run_fio "W Seq128K Q32T1" write 128k 32 1 $BLUE
  run_fio "W Rnd4K   Q32T16" randwrite 4k 32 16 $RED
  run_fio "W Rnd4K   Q1T1" randwrite 4k 1 1 $RED
  
  cleanup
}



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
  orphans=$(pacman -Qtdq) && [[ -n $orphans ]] && sudo pacman -Rns --noconfirm $orphans # remove orphaned packages
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