#!/bin/bash

# Initialize brightness file if it doesn't exist
if [ ! -f /tmp/waybar_brightness ]; then
    echo 󰃠 > /tmp/waybar_brightness
fi

# Read current brightness value
cat /tmp/waybar_brightness
