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
sleep 3

if [ $XRECOVER = false ]; then
	#Start programs
	unclutter -idle 5&
	ktimer&
	redshift -t 5500K:3000K &
	nemo -n
fi

# remap button right of left shift on iso keyboards to escape
xmodmap -e "keycode 94 = Escape"
# Add åäö keys
xmodmap -e "keycode 24 = semicolon colon 0x0 0x0 aring Aring"
xmodmap -e "keycode 25 = period less 0x0 0x0 adiaeresis Adiaeresis"
xmodmap -e "keycode 26 = period greater 0x0 0x0 0x0f6 0x0d6"
# Special symbols
xmodmap -e "keysym a = a A 0x0 0x0 aacute agrave"
xmodmap -e "keysym e = e E 0x0 0x0 eacute egrave"
xmodmap -e "keysym c = c C 0x0 0x0 ccedilla ccedilla"
# increase keyboard repeat rate
xset r rate 160 30


