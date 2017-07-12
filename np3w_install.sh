#!/bin/bash

# Script that sets up a nice linux environment
ln -sf ~/proj/Misc/.vimrc ~/.vimrc

mkdir -p ~/.config/nvim
ln -sf ~/proj/Misc/.vimrc ~/.config/nvim/init.vim

ln -sf ~/proj/Misc/.zshrc ~/.zshrc
ln -sf ~/proj/Misc/.screenrc ~/.screenrc

sudo ln -sf ~/proj/Misc/20_np_suspend /lib/systemd/system-sleep/20_np_suspend

mkdir -p ~/.config/i3
ln -sf ~/proj/Misc/i3_config ~/.config/i3/config

git config --global user.email np3w.np3w@gmail.com
git config --global user.name Np3w
git config --global push.default simple

