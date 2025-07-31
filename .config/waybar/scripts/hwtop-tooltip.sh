#!/bin/bash

HOVER_FILE="/tmp/waybar_hwtop_hovered"

if [[ -f "$HOVER_FILE" ]]; then
    hwtop waybar
    count=$(cat "$HOVER_FILE" 2>/dev/null || echo 0)
    count=$((count + 1))
    echo "$count" > "$HOVER_FILE"
    if [[ $count -ge 60 ]]; then
        rm -f "$HOVER_FILE"
    fi
else
    echo '{"tooltip":""}'
fi