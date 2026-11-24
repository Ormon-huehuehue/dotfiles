#!/usr/bin/env sh
# Hyprland 0.57 prints 'bool: true'; 1 = animations on = switch game mode ON
HYPRGAMEMODE=$(hyprctl -j getoption animations:enabled | jq -r 'if .bool then 1 else 0 end')

# Waybar performance
FILE="$HOME/.config/waybar/style.css"

sed -i 's/\/\* \(.*animation:.*\) \*\//\1/g' $FILE
sed -i 's/\/\* \(.*transition:.*\) \*\//\1/g' $FILE
if [ $HYPRGAMEMODE = 1 ]; then
	sed -i 's/^\(.*animation:.*\)$/\/\* \1 \*\//g' $FILE
	sed -i 's/^\(.*transition:.*\)$/\/\* \1 \*\//g' $FILE
fi
pkill -x waybar
hyprctl dispatch 'hl.dsp.exec_cmd("waybar")' >/dev/null

# Hyprland performance
if [ $HYPRGAMEMODE = 1 ]; then
	hyprctl eval 'hl.config({
        animations = { enabled = false },
        decoration = { blur = { enabled = false }, rounding = 0 },
        general = { gaps_in = 0, gaps_out = 0, border_size = 1 },
    })'
	exit
else
	hyprctl reload
fi
