#!/bin/bash 

PKGS="xbacklight nitrogen xcompmgr xmodmap mrxvt dmenu terminator pcmanfm compton"

for p in $PKGS
do
    equo install $p
done
