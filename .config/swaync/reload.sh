#!/bin/bash
CONFIG_FILES="$HOME/.config/swaync/config.json $HOME/.config/swaync/style.css"

trap "killall swaync" EXIT

while true; do
    swaync &
    inotifywait -e create,modify $CONFIG_FILES
    killall swaync
done