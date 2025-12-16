#!/bin/bash

dbus-monitor --session "type='signal',interface='org.kde.ScreenSaver'"|
  (
    while true
    do
      read X
      if grep "boolean false" <<< "$X" &> /dev/null; then
        systemctl --user restart plasma-plasmashell.service
        echo "Screen Unlocked! Running command.."
      fi
    done
    )
