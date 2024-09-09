#!/usr/bin/env sh

hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap'
