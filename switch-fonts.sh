#!/bin/bash

mv ~/.dotfiles/home/.config/alacritty/alacritty-other.toml ~/.dotfiles/home/.config/alacritty/alacritty-other-tmp.toml
cp ~/.dotfiles/home/.config/alacritty/alacritty.toml ~/.dotfiles/home/.config/alacritty/alacritty-other.toml
mv ~/.dotfiles/home/.config/alacritty/alacritty-other-tmp.toml ~/.dotfiles/home/.config/alacritty/alacritty.toml
