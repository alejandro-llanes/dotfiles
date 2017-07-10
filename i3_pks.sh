#!/bin/bash 

PKGS="xbacklight nitrogen xcompmgr xmodmap mrxvt dmenu"

for p in $PKGS
do
    equo install $p
done
