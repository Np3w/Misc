#!/bin/sh

# This is based on i3-sensible-terminal

#
# This code is released in public domain by Han Boetes <han@mijncomputer.nl>
#
# This script tries to exec a terminal emulator by trying some known terminal
# emulators.
#
# We welcome patches that add distribution-specific mechanisms to find the
# preferred terminal emulator. On Debian, there is the x-terminal-emulator
# symlink for example.

for terminal in gnome-terminal $TERMINAL x-terminal-emulator urxvt rxvt terminator Eterm aterm xterm gnome-terminal roxterm xfce4-terminal termite lxterminal mate-terminal terminology; do
    if command -v $terminal > /dev/null 2>&1; then
        exec $terminal "$@"
    fi
done

