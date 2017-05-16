#!/bin/bash
# Np3w's initialization script

####
# Read command line arguments
XRECOVER=false
while [[ $# -gt 0 ]]
do
	case "$1" in --xrecover)
	XRECOVER=true
	shift
	;;
	*)
	# unknown option
	echo "Unknown argument $1"
	exit 1
	;;
	esac
done

####
# Actually do stuff

# Seems to fail sometimes without the sleep
sleep 2

if [ $XRECOVER = false ]; then
	# Program that hides mouse pointer if it is not moving
	unclutter -idle 5&
	# Timer program
	ktimer&
	# Blue light filter
	redshift -t 5500K:2750K &
	# Desktop icons
	nemo -n
fi

# remap button right of left shift on iso keyboards to escape
xmodmap -e "keycode 94 = Escape"

# Add åäö to keyboard
xmodmap -e "keycode 24 = semicolon colon 0x0 0x0 aring Aring"
xmodmap -e "keycode 25 = comma less 0x0 0x0 adiaeresis Adiaeresis"
xmodmap -e "keycode 26 = period greater 0x0 0x0 0x0f6 0x0d6"

# á and à
xmodmap -e "keysym a = a A 0x0 0x0 aacute agrave"

# é and è
xmodmap -e "keysym e = e E 0x0 0x0 eacute egrave"

# 
xmodmap -e "keysym u = u U 0x0 0x0 ecircumflex Ecircumflex"

# ç
xmodmap -e "keysym c = c C 0x0 0x0 ccedilla ccedilla"

# increase keyboard repeat rate
xset r rate 160 30


