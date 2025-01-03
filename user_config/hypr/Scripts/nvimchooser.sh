#!/bin/bash

# https://michaeluloth.com/neovim-switch-configs/

export PATH=$HOME/.local/bin:$PATH

# Define the options
OPTIONS="Kickstart\nAstronvim\nLiteVim\nNvChad\nSpaceVim\nLazyVim\nLunarVim"

# Launch Rofi and capture the choice
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "Choose an framework:")


# Map the selection to Hyprland actions
case "$CHOICE" in
    "Kickstart")
        hyprctl dispatch exec neovide
        ;;
    "Astronvim")
        hyprctl dispatch exec env NVIM_APPNAME=astronvim neovide
        ;;
    "LiteVim")
        hyprctl dispatch exec env NVIM_APPNAME=litevim neovide
        ;;
    "NvChad")
        hyprctl dispatch exec env NVIM_APPNAME=nvchad neovide
        ;;
    "SpaceVim")
        hyprctl dispatch exec env NVIM_APPNAME=spacevim neovide
        ;;
    "LazyVim")
        hyprctl dispatch exec env NVIM_APPNAME=lazyvim neovide
        ;;
    "LunarVim")
        hyprctl dispatch exec neovide --neovim-bin lvim
        ;;
    *)
        notify-send "No valid option selected"
        ;;
esac

