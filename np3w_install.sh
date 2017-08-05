#!/bin/bash

# Script that sets up a nice linux environment

echo "Installing vim/neovim configuration"
ln -sf ~/proj/Misc/.vimrc ~/.vimrc
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

# Download tools and libraries
if [ ! -d ~/proj/np_libs ] ; then
	git clone git@github.com:Np3w/Libs.git ~/proj/np_libs
else
	echo "Not downloading np_libs because they already exist"
fi

echo "Installing np tools"
pushd ~/proj/np_libs
	make
	sudo make install_tools
popd


