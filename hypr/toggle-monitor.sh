#!/bin/bash
# Flips HDMI-A-1 between external (2560x1440) and home (1920x1080) lines in monitors.lua.
CONFIG_FILE="$HOME/.config/hypr/monitors.lua"

if grep -q "^hl.monitor({ output = \"HDMI-A-1\", mode = \"2560x1440" "$CONFIG_FILE"; then
  sed -i "s|^hl.monitor({ output = \"HDMI-A-1\", mode = \"2560x1440|-- &|" "$CONFIG_FILE"
  sed -i "s|^-- \(hl.monitor({ output = \"HDMI-A-1\", mode = \"1920x1080\)|\1|" "$CONFIG_FILE"
  notify-send "Monitor" "Switched to home (1920x1080)"
else
  sed -i "s|^hl.monitor({ output = \"HDMI-A-1\", mode = \"1920x1080|-- &|" "$CONFIG_FILE"
  sed -i "s|^-- \(hl.monitor({ output = \"HDMI-A-1\", mode = \"2560x1440\)|\1|" "$CONFIG_FILE"
  notify-send "Monitor" "Switched to external (2560x1440)"
fi

hyprctl reload
