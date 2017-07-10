#!/bin/bash 

PKGS="xbacklight nitrogen xcompmgr xmodmap mrxvt dmenu terminator"

for p in $PKGS
do
    equo install $p
done
