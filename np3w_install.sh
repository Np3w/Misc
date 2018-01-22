#!/bin/bash

# Script that sets up a nice linux environment

# Install packages using apt
INSTALL_PACKAGES=1

if [[ $INSTALL_PACKAGES -eq 1 ]] ; then
	echo "Installing packages"
	sudo apt install git
	sudo apt install subversion

	sudo apt install gcc
	sudo apt install g++
	sudo apt install clang
	sudo apt install build-essentials

	sudo apt install cgdb
	sudo apt install gdb

	sudo apt install i3-wm

	sudo apt install ssh

	sudo apt install xclip
fi

echo "Installing vim config"
ln -sf ~/proj/Misc/.vimrc ~/.vimrc

echo "Installing neovim config"
mkdir -p ~/.config/nvim
ln -sf ~/proj/Misc/.vimrc ~/.config/nvim/init.vim

echo "Installing shell configuration files"
ln -sf ~/proj/Misc/.zshrc ~/.zshrc
ln -sf ~/proj/Misc/.screenrc ~/.screenrc

echo "Installing 20_np_suspend script"
sudo ln -sf ~/proj/Misc/20_np_suspend /lib/systemd/system-sleep/20_np_suspend

echo "Setting up i3wm configuration"
mkdir -p ~/.config/i3
ln -sf ~/proj/Misc/i3_config ~/.config/i3/config

echo "Setting up git"
git config --global user.email np3w.np3w@gmail.com
git config --global user.name Np3w
git config --global push.default simple

echo "Installing 4coder starter program"
sudo ln -sf ~/proj/Misc/4ed /usr/bin/4ed

FCODER_DIR="$HOME/programs/4coder"
if [ -d $FCODER_DIR ] ; then
	echo "Compiling and installing 4coder configuration"
	pushd 4coder/
		./build.sh $FCODER_DIR
	popd
else
	echo "4coder not installed in \"$FCODER_DIR\". Not installing 4coder configuration"
fi

HAVE_NP_LIBS=0

# Download tools and libraries
if [ ! -d ~/proj/np_libs ] ; then
	git clone git@github.com:Np3w/Libs.git ~/proj/np_libs
	if [[ $? -eq 0 ]] ; then
		HAVE_NP_LIBS=1
	else
		echo "Failed to download np_libs"
	fi
else
	echo "Not downloading np_libs because they already exist"
	HAVE_NP_LIBS=1
fi

if [[ $HAVE_NP_LIBS -eq 1 ]] ; then
	echo "Installing np tools"
	pushd ~/proj/np_libs
		make
		sudo make install_tools
	popd
fi


