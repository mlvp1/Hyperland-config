#!/bin/bash
wall=$(swww query | awk -F 'image: ' '{print $2}')
cp "$wall" /home/yassine/Desktop/tmp.jpg &
hyprctl dispatch movecursor 960 240 &


wait
sleep 0.7
# hyprctl keyword decoration:active_opacity 0.5 &
# hyprctl keyword decoration:inactive_opacity 0.5 &


systemd-run --user bash -c 'sleep 0.1; hyprlock; sleep0.2 ; hyprctl keyword decoration:active_opacity 1; hyprctl keyword decoration:inactive_opacity 1'