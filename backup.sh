#!/bin/bash

cp -r ~/.config/alacritty config/
cp -r ~/.config/htop config/
cp -r ~/.config/nvim config/
cp -r ~/.config/sketchybar config/

cp -r ~/.zprofile home/
cp -r ~/.zshrc home/
cp -r ~/.vimrc home/

mkdir -p home/.vscode
cp -r ~/.vscode/settings.json home/.vscode/
