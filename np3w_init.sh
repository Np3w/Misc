#!/bin/bash
# Np3w's initialization script

####
# Read command line arguments
XRECOVER=false
# Terraria has a very annoying bug when the keyboard repeat rate is super high
TERRARIA_MODE=false
while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
		--xrecover)
		XRECOVER=true
		shift
		;;

		--terraria)
		TERRARIA_MODE=true
		shift
		;;

		# unknown option
		*)
		echo "Unknown argument $1"
		exit 1
		;;
	esac
done

echo "Terraria mode: $TERRARIA_MODE, X recover: $XRECOVER"

####
# Actually do stuff

# Seems to fail sometimes without the sleep
sleep 2

#if [ $XRECOVER = false ]; then
	# Program that hides mouse pointer if it is not moving
	#unclutter -idle 5&
	# Timer program
	#ktimer&
	# Blue light filter
	#redshift -t 5500K:2750K &
	# Desktop icons
	#nemo -n
#fi

######################## Setup keyboard

echo "Setting up keyboard... (becuase xmodmap is SUPER SLOW this might take a while, ~20seconds on my computer)"
sleep 0.1

# These might need to be swapped for certain keyboards
xmodmap -e "keycode  94 = apostrophe quotedbl z Z dead_acute dead_doubleacute"
xmodmap -e "keycode  52 = Escape NoSymbol Escape"

# These too
#xmodmap -e "keycode  21 = numbersign grave equal plus dead_grave"
#xmodmap -e "keycode  49 = dollar asciitilde grave asciitilde dead_tilde dead_tilde"

xmodmap -e "keycode  49 = numbersign grave equal plus dead_grave"
xmodmap -e "keycode  21 = dollar asciitilde grave asciitilde dead_tilde dead_tilde"

# @todo Possible solution to this being super slow: write Xmodmap file and make Xmodmap read from it
#xmodmap -e "keycode   8 ="
xmodmap -e "keycode   9 = Escape NoSymbol Escape"
xmodmap -e "keycode  10 = ampersand percent 1 exclam"
xmodmap -e "keycode  11 = bracketleft 7 2 at currency"
xmodmap -e "keycode  12 = braceleft 5 3 numbersign cent"
xmodmap -e "keycode  13 = braceright 3 4 dollar yen"
xmodmap -e "keycode  14 = parenleft 1 5 percent EuroSign"
xmodmap -e "keycode  15 = equal 9 6 asciicircum sterling dead_circumflex"
xmodmap -e "keycode  16 = asterisk 0 7 ampersand"
xmodmap -e "keycode  17 = parenright 2 8 asterisk onehalf"
xmodmap -e "keycode  18 = plus 4 9 parenleft dead_grave"
xmodmap -e "keycode  19 = bracketright 6 0 parenright"
xmodmap -e "keycode  20 = exclam 8 minus underscore exclamdown U2E18"


xmodmap -e "keycode  22 = BackSpace BackSpace BackSpace BackSpace"
xmodmap -e "keycode  23 = Tab ISO_Left_Tab Tab ISO_Left_Tab"
xmodmap -e "keycode  24 = semicolon colon q Q aring Aring"
xmodmap -e "keycode  25 = comma less w W adiaeresis Adiaeresis"
xmodmap -e "keycode  26 = period greater e E 0x0f6 0x0d6"
xmodmap -e "keycode  27 = p P r R paragraph section"
xmodmap -e "keycode  28 = y Y t T udiaeresis Udiaeresis"
xmodmap -e "keycode  29 = f F y Y"
xmodmap -e "keycode  30 = g G u U"
xmodmap -e "keycode  31 = c C i I ccedilla Ccedilla"
xmodmap -e "keycode  32 = r R o O registered trademark"
xmodmap -e "keycode  33 = l L p P"
xmodmap -e "keycode  34 = slash question bracketleft braceleft questiondown U203D"
xmodmap -e "keycode  35 = at asciicircum bracketright braceright dead_circumflex dead_caron"
xmodmap -e "keycode  36 = Return NoSymbol Return"
xmodmap -e "keycode  37 = Control_L NoSymbol Control_L"
xmodmap -e "keycode  38 = a A a A aacute agrave"
xmodmap -e "keycode  39 = o O s S oslash Oslash"
xmodmap -e "keycode  40 = e E d D eacute egrave"
xmodmap -e "keycode  41 = u U f F udiaeresis Udiaeresis"
xmodmap -e "keycode  42 = i I g G"
xmodmap -e "keycode  43 = d D h H eth ETH"
xmodmap -e "keycode  44 = h H j J dead_acute"
xmodmap -e "keycode  45 = t T k K thorn THORN"
xmodmap -e "keycode  46 = n N l L ntilde Ntilde"
xmodmap -e "keycode  47 = s S semicolon colon ssharp"
xmodmap -e "keycode  48 = minus underscore apostrophe quotedbl hyphen endash"


xmodmap -e "keycode  50 = Shift_L NoSymbol Shift_L"
xmodmap -e "keycode  51 = backslash bar backslash bar"

xmodmap -e "keycode  53 = q Q x X"
xmodmap -e "keycode  54 = j J c C ecircumflex Ecircumflex"
xmodmap -e "keycode  55 = k K v V"
xmodmap -e "keycode  56 = x X b B"
xmodmap -e "keycode  57 = b B n N"
xmodmap -e "keycode  58 = m M m M"
xmodmap -e "keycode  59 = w W comma less"
xmodmap -e "keycode  60 = v V period greater"
xmodmap -e "keycode  61 = z Z slash question"
xmodmap -e "keycode  62 = Shift_R NoSymbol Shift_R"
xmodmap -e "keycode  63 = KP_Multiply KP_Multiply KP_Multiply KP_Multiply KP_Multiply KP_Multiply XF86ClearGrab KP_Multiply KP_Multiply XF86ClearGrab"
xmodmap -e "keycode  64 = Alt_L Meta_L Alt_L Meta_L"
xmodmap -e "keycode  65 = space NoSymbol space"
xmodmap -e "keycode  66 = Caps_Lock NoSymbol Caps_Lock"
xmodmap -e "keycode  67 = F1 F1 F1 F1 F1 F1 XF86Switch_VT_1 F1 F1 XF86Switch_VT_1"
xmodmap -e "keycode  68 = F2 F2 F2 F2 F2 F2 XF86Switch_VT_2 F2 F2 XF86Switch_VT_2"
xmodmap -e "keycode  69 = F3 F3 F3 F3 F3 F3 XF86Switch_VT_3 F3 F3 XF86Switch_VT_3"
xmodmap -e "keycode  70 = F4 F4 F4 F4 F4 F4 XF86Switch_VT_4 F4 F4 XF86Switch_VT_4"
xmodmap -e "keycode  71 = F5 F5 F5 F5 F5 F5 XF86Switch_VT_5 F5 F5 XF86Switch_VT_5"
xmodmap -e "keycode  72 = F6 F6 F6 F6 F6 F6 XF86Switch_VT_6 F6 F6 XF86Switch_VT_6"
xmodmap -e "keycode  73 = F7 F7 F7 F7 F7 F7 XF86Switch_VT_7 F7 F7 XF86Switch_VT_7"
xmodmap -e "keycode  74 = F8 F8 F8 F8 F8 F8 XF86Switch_VT_8 F8 F8 XF86Switch_VT_8"
xmodmap -e "keycode  75 = F9 F9 F9 F9 F9 F9 XF86Switch_VT_9 F9 F9 XF86Switch_VT_9"
xmodmap -e "keycode  76 = F10 F10 F10 F10 F10 F10 XF86Switch_VT_10 F10 F10 XF86Switch_VT_10"
xmodmap -e "keycode  77 = Num_Lock NoSymbol Num_Lock"
xmodmap -e "keycode  78 = Scroll_Lock NoSymbol Scroll_Lock"
xmodmap -e "keycode  79 = KP_Home KP_7 KP_Home KP_7"
xmodmap -e "keycode  80 = KP_Up KP_8 KP_Up KP_8"
xmodmap -e "keycode  81 = KP_Prior KP_9 KP_Prior KP_9"
xmodmap -e "keycode  82 = KP_Subtract KP_Subtract KP_Subtract KP_Subtract KP_Subtract KP_Subtract XF86Prev_VMode KP_Subtract KP_Subtract XF86Prev_VMode"
xmodmap -e "keycode  83 = KP_Left KP_4 KP_Left KP_4"
xmodmap -e "keycode  84 = KP_Begin KP_5 KP_Begin KP_5"
xmodmap -e "keycode  85 = KP_Right KP_6 KP_Right KP_6"
xmodmap -e "keycode  86 = KP_Add KP_Add KP_Add KP_Add KP_Add KP_Add XF86Next_VMode KP_Add KP_Add XF86Next_VMode"
xmodmap -e "keycode  87 = KP_End KP_1 KP_End KP_1"
xmodmap -e "keycode  88 = KP_Down KP_2 KP_Down KP_2"
xmodmap -e "keycode  89 = KP_Next KP_3 KP_Next KP_3"
xmodmap -e "keycode  90 = KP_Insert KP_0 KP_Insert KP_0"
xmodmap -e "keycode  91 = KP_Delete KP_Decimal KP_Delete KP_Decimal"
xmodmap -e "keycode  92 = ISO_Level3_Shift NoSymbol ISO_Level3_Shift"


xmodmap -e "keycode  95 = F11 F11 F11 F11 F11 F11 XF86Switch_VT_11 F11 F11 XF86Switch_VT_11"
xmodmap -e "keycode  96 = F12 F12 F12 F12 F12 F12 XF86Switch_VT_12 F12 F12 XF86Switch_VT_12"
#xmodmap -e "keycode  97 ="
#xmodmap -e "keycode  98 = Katakana NoSymbol Katakana"
#xmodmap -e "keycode  99 = Hiragana NoSymbol Hiragana"
#xmodmap -e "keycode 100 = Henkan_Mode NoSymbol Henkan_Mode"
#xmodmap -e "keycode 101 = Hiragana_Katakana NoSymbol Hiragana_Katakana"
#xmodmap -e "keycode 102 = Muhenkan NoSymbol Muhenkan"
#xmodmap -e "keycode 103 ="
xmodmap -e "keycode 104 = KP_Enter NoSymbol KP_Enter"
xmodmap -e "keycode 105 = Control_R NoSymbol Control_R"
xmodmap -e "keycode 106 = KP_Divide KP_Divide KP_Divide KP_Divide KP_Divide KP_Divide XF86Ungrab KP_Divide KP_Divide XF86Ungrab"
xmodmap -e "keycode 107 = Print Sys_Req Print Sys_Req"
xmodmap -e "keycode 108 = ISO_Level3_Shift NoSymbol ISO_Level3_Shift"
xmodmap -e "keycode 109 = Linefeed NoSymbol Linefeed"
xmodmap -e "keycode 110 = Home NoSymbol Home"
xmodmap -e "keycode 111 = Up NoSymbol Up"
xmodmap -e "keycode 112 = Prior NoSymbol Prior"
xmodmap -e "keycode 113 = Left NoSymbol Left"
xmodmap -e "keycode 114 = Right NoSymbol Right"
xmodmap -e "keycode 115 = End NoSymbol End"
xmodmap -e "keycode 116 = Down NoSymbol Down"
xmodmap -e "keycode 117 = Next NoSymbol Next"
xmodmap -e "keycode 118 = Insert NoSymbol Insert"
xmodmap -e "keycode 119 = Delete NoSymbol Delete"
#xmodmap -e "keycode 120 ="
xmodmap -e "keycode 121 = XF86AudioMute NoSymbol XF86AudioMute"
xmodmap -e "keycode 122 = XF86AudioLowerVolume NoSymbol XF86AudioLowerVolume"
xmodmap -e "keycode 123 = XF86AudioRaiseVolume NoSymbol XF86AudioRaiseVolume"
xmodmap -e "keycode 124 = XF86PowerOff NoSymbol XF86PowerOff"
xmodmap -e "keycode 125 = KP_Equal NoSymbol KP_Equal"
xmodmap -e "keycode 126 = plusminus NoSymbol plusminus"
xmodmap -e "keycode 127 = Pause Break Pause Break"
xmodmap -e "keycode 128 = XF86LaunchA NoSymbol XF86LaunchA"
xmodmap -e "keycode 129 = KP_Decimal KP_Decimal KP_Decimal KP_Decimal"
xmodmap -e "keycode 130 = Hangul NoSymbol Hangul"
xmodmap -e "keycode 131 = Hangul_Hanja NoSymbol Hangul_Hanja"
#xmodmap -e "keycode 132 ="
xmodmap -e "keycode 133 = Super_L NoSymbol Super_L"
xmodmap -e "keycode 134 = Super_R NoSymbol Super_R"
xmodmap -e "keycode 135 = Menu NoSymbol Menu"
xmodmap -e "keycode 136 = Cancel NoSymbol Cancel"
xmodmap -e "keycode 137 = Redo NoSymbol Redo"
xmodmap -e "keycode 138 = SunProps NoSymbol SunProps"
xmodmap -e "keycode 139 = Undo NoSymbol Undo"
xmodmap -e "keycode 140 = SunFront NoSymbol SunFront"
xmodmap -e "keycode 141 = XF86Copy NoSymbol XF86Copy"
xmodmap -e "keycode 142 = XF86Open NoSymbol XF86Open"
xmodmap -e "keycode 143 = XF86Paste NoSymbol XF86Paste"
xmodmap -e "keycode 144 = Find NoSymbol Find"
xmodmap -e "keycode 145 = XF86Cut NoSymbol XF86Cut"
xmodmap -e "keycode 146 = Help NoSymbol Help"
xmodmap -e "keycode 147 = XF86MenuKB NoSymbol XF86MenuKB"
xmodmap -e "keycode 148 = XF86Calculator NoSymbol XF86Calculator"
#xmodmap -e "keycode 149 ="
xmodmap -e "keycode 150 = XF86Sleep NoSymbol XF86Sleep"
xmodmap -e "keycode 151 = XF86WakeUp NoSymbol XF86WakeUp"
xmodmap -e "keycode 152 = XF86Explorer NoSymbol XF86Explorer"
xmodmap -e "keycode 153 = XF86Send NoSymbol XF86Send"
#xmodmap -e "keycode 154 ="
xmodmap -e "keycode 155 = XF86Xfer NoSymbol XF86Xfer"
xmodmap -e "keycode 156 = XF86Launch1 NoSymbol XF86Launch1"
xmodmap -e "keycode 157 = XF86Launch2 NoSymbol XF86Launch2"
xmodmap -e "keycode 158 = XF86WWW NoSymbol XF86WWW"
xmodmap -e "keycode 159 = XF86DOS NoSymbol XF86DOS"
xmodmap -e "keycode 160 = XF86ScreenSaver NoSymbol XF86ScreenSaver"
xmodmap -e "keycode 161 = XF86RotateWindows NoSymbol XF86RotateWindows"
xmodmap -e "keycode 162 = XF86TaskPane NoSymbol XF86TaskPane"
xmodmap -e "keycode 163 = XF86Mail NoSymbol XF86Mail"
xmodmap -e "keycode 164 = XF86Favorites NoSymbol XF86Favorites"
xmodmap -e "keycode 165 = XF86MyComputer NoSymbol XF86MyComputer"
xmodmap -e "keycode 166 = XF86Back NoSymbol XF86Back"
xmodmap -e "keycode 167 = XF86Forward NoSymbol XF86Forward"
#xmodmap -e "keycode 168 ="
xmodmap -e "keycode 169 = XF86Eject NoSymbol XF86Eject"
xmodmap -e "keycode 170 = XF86Eject XF86Eject XF86Eject XF86Eject"
xmodmap -e "keycode 171 = XF86AudioNext NoSymbol XF86AudioNext"
xmodmap -e "keycode 172 = XF86AudioPlay XF86AudioPause XF86AudioPlay XF86AudioPause"
xmodmap -e "keycode 173 = XF86AudioPrev NoSymbol XF86AudioPrev"
xmodmap -e "keycode 174 = XF86AudioStop XF86Eject XF86AudioStop XF86Eject"
xmodmap -e "keycode 175 = XF86AudioRecord NoSymbol XF86AudioRecord"
xmodmap -e "keycode 176 = XF86AudioRewind NoSymbol XF86AudioRewind"
xmodmap -e "keycode 177 = XF86Phone NoSymbol XF86Phone"
#xmodmap -e "keycode 178 ="
xmodmap -e "keycode 179 = XF86Tools NoSymbol XF86Tools"
xmodmap -e "keycode 180 = XF86HomePage NoSymbol XF86HomePage"
xmodmap -e "keycode 181 = XF86Reload NoSymbol XF86Reload"
xmodmap -e "keycode 182 = XF86Close NoSymbol XF86Close"
#xmodmap -e "keycode 183 ="
#xmodmap -e "keycode 184 ="
xmodmap -e "keycode 185 = XF86ScrollUp NoSymbol XF86ScrollUp"
xmodmap -e "keycode 186 = XF86ScrollDown NoSymbol XF86ScrollDown"
xmodmap -e "keycode 187 = parenleft NoSymbol parenleft"
xmodmap -e "keycode 188 = parenright NoSymbol parenright"
xmodmap -e "keycode 189 = XF86New NoSymbol XF86New"
xmodmap -e "keycode 190 = Redo NoSymbol Redo"
xmodmap -e "keycode 191 = XF86Tools NoSymbol XF86Tools"
xmodmap -e "keycode 192 = XF86Launch5 NoSymbol XF86Launch5"
xmodmap -e "keycode 193 = XF86Launch6 NoSymbol XF86Launch6"
xmodmap -e "keycode 194 = XF86Launch7 NoSymbol XF86Launch7"
xmodmap -e "keycode 195 = XF86Launch8 NoSymbol XF86Launch8"
xmodmap -e "keycode 196 = XF86Launch9 NoSymbol XF86Launch9"
#xmodmap -e "keycode 197 ="
xmodmap -e "keycode 198 = XF86AudioMicMute NoSymbol XF86AudioMicMute"
xmodmap -e "keycode 199 = XF86TouchpadToggle NoSymbol XF86TouchpadToggle"
xmodmap -e "keycode 200 = XF86TouchpadOn NoSymbol XF86TouchpadOn"
xmodmap -e "keycode 201 = XF86TouchpadOff NoSymbol XF86TouchpadOff"
#xmodmap -e "keycode 202 ="
xmodmap -e "keycode 203 = Mode_switch NoSymbol Mode_switch"
xmodmap -e "keycode 204 = NoSymbol Alt_L NoSymbol Alt_L"
xmodmap -e "keycode 205 = NoSymbol Meta_L NoSymbol Meta_L"
xmodmap -e "keycode 206 = NoSymbol Super_L NoSymbol Super_L"
xmodmap -e "keycode 207 = NoSymbol Hyper_L NoSymbol Hyper_L"
xmodmap -e "keycode 208 = XF86AudioPlay NoSymbol XF86AudioPlay"
xmodmap -e "keycode 209 = XF86AudioPause NoSymbol XF86AudioPause"
xmodmap -e "keycode 210 = XF86Launch3 NoSymbol XF86Launch3"
xmodmap -e "keycode 211 = XF86Launch4 NoSymbol XF86Launch4"
xmodmap -e "keycode 212 = XF86LaunchB NoSymbol XF86LaunchB"
xmodmap -e "keycode 213 = XF86Suspend NoSymbol XF86Suspend"
xmodmap -e "keycode 214 = XF86Close NoSymbol XF86Close"
xmodmap -e "keycode 215 = XF86AudioPlay NoSymbol XF86AudioPlay"
xmodmap -e "keycode 216 = XF86AudioForward NoSymbol XF86AudioForward"
#xmodmap -e "keycode 217 ="
xmodmap -e "keycode 218 = Print NoSymbol Print"
#xmodmap -e "keycode 219 ="
xmodmap -e "keycode 220 = XF86WebCam NoSymbol XF86WebCam"
#xmodmap -e "keycode 221 ="
#xmodmap -e "keycode 222 ="
xmodmap -e "keycode 223 = XF86Mail NoSymbol XF86Mail"
xmodmap -e "keycode 224 = XF86Messenger NoSymbol XF86Messenger"
xmodmap -e "keycode 225 = XF86Search NoSymbol XF86Search"
xmodmap -e "keycode 226 = XF86Go NoSymbol XF86Go"
xmodmap -e "keycode 227 = XF86Finance NoSymbol XF86Finance"
xmodmap -e "keycode 228 = XF86Game NoSymbol XF86Game"
xmodmap -e "keycode 229 = XF86Shop NoSymbol XF86Shop"
#xmodmap -e "keycode 230 ="
xmodmap -e "keycode 231 = Cancel NoSymbol Cancel"
xmodmap -e "keycode 232 = XF86MonBrightnessDown NoSymbol XF86MonBrightnessDown"
xmodmap -e "keycode 233 = XF86MonBrightnessUp NoSymbol XF86MonBrightnessUp"
xmodmap -e "keycode 234 = XF86AudioMedia NoSymbol XF86AudioMedia"
xmodmap -e "keycode 235 = XF86Display NoSymbol XF86Display"
xmodmap -e "keycode 236 = XF86KbdLightOnOff NoSymbol XF86KbdLightOnOff"
xmodmap -e "keycode 237 = XF86KbdBrightnessDown NoSymbol XF86KbdBrightnessDown"
xmodmap -e "keycode 238 = XF86KbdBrightnessUp NoSymbol XF86KbdBrightnessUp"
xmodmap -e "keycode 239 = XF86Send NoSymbol XF86Send"
xmodmap -e "keycode 240 = XF86Reply NoSymbol XF86Reply"
xmodmap -e "keycode 241 = XF86MailForward NoSymbol XF86MailForward"
xmodmap -e "keycode 242 = XF86Save NoSymbol XF86Save"
xmodmap -e "keycode 243 = XF86Documents NoSymbol XF86Documents"
xmodmap -e "keycode 244 = XF86Battery NoSymbol XF86Battery"
xmodmap -e "keycode 245 = XF86Bluetooth NoSymbol XF86Bluetooth"
xmodmap -e "keycode 246 = XF86WLAN NoSymbol XF86WLAN"
#xmodmap -e "keycode 247 ="
#xmodmap -e "keycode 248 ="
#xmodmap -e "keycode 249 ="
#xmodmap -e "keycode 250 ="
#xmodmap -e "keycode 251 ="
#xmodmap -e "keycode 252 ="
#xmodmap -e "keycode 253 ="
#xmodmap -e "keycode 254 ="
#xmodmap -e "keycode 255 ="

echo "... done setting up keyboard"

########################

# increase keyboard repeat rate
xset r rate 160 30

if [ $TERRARIA_MODE = true ]; then
	xset r rate 500 2
fi


