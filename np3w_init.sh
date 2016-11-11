#!/bin/bash
# Np3w's initialization script

# Seems to fail more often without the sleep
sleep 10 

unclutter -idle 5&
ktimer&
redshift &

# remap button right of left shift on nordic keyboards to escape
xmodmap -e "keycode 94 = Escape"
# increase keyboard repeat rate
xset r rate 160 30
