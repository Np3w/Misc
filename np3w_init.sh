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
	#ktimer&
	redshift -t 5500K:2000K &
	nemo -n
fi

# remap button right of left shift on nordic keyboards to escape
xmodmap -e "keycode 94 = Escape"
# increase keyboard repeat rate
xset r rate 160 30
