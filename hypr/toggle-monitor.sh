#!/bin/bash
CONFIG_FILE="$HOME/.config/hypr/monitors.conf"

if grep -q "^monitor = HDMI-A-1, 2560x1440" "$CONFIG_FILE"; then
  # External is active, switch to home
  sed -i 's/^monitor = HDMI-A-1, 2560x1440/#monitor = HDMI-A-1, 2560x1440/' "$CONFIG_FILE"
  sed -i 's/^#monitor = HDMI-A-1, 1920x1080/monitor = HDMI-A-1, 1920x1080/' "$CONFIG_FILE"
  notify-send "Monitor" "Switched to home (1920x1080)"
else
  # Home is active, switch to external
  sed -i 's/^monitor = HDMI-A-1, 1920x1080/#monitor = HDMI-A-1, 1920x1080/' "$CONFIG_FILE"
  sed -i 's/^#monitor = HDMI-A-1, 2560x1440/monitor = HDMI-A-1, 2560x1440/' "$CONFIG_FILE"
  notify-send "Monitor" "Switched to external (2560x1440)"
fi

hyprctl reload
