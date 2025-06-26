#!/bin/bash

output_status() {
    local count dnd prefix="" suffix="" plural=""
    
    # Get current state
    count=$(swaync-client -c 2>/dev/null) || return 1
    dnd=$(swaync-client -D 2>/dev/null) || return 1
    
    if [[ $dnd == "true" ]]; then
        prefix="dnd-"
        suffix=" (DND)"
    fi
    
    if [[ $count -eq 0 ]]; then
        printf '{"text": "", "alt": "%snone", "tooltip": "No notifications%s", "class": "%snone"}\n' \
               "$prefix" "$suffix" "$prefix"
    else
        [[ $count -gt 1 ]] && plural="s"
        printf '{"text": "%d", "alt": "%snotification", "tooltip": "%d notification%s%s", "class": "%snotification"}\n' \
               "$count" "$prefix" "$count" "$plural" "$suffix" "$prefix"
    fi
}

# Output initial status
output_status

# Subscribe to events and update on changes
swaync-client --subscribe 2>/dev/null | while read -r event; do
    case "$event" in
        *"notification"*|*"dnd"*|*"count"*)
            output_status
            ;;
    esac
done