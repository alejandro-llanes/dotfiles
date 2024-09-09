#!/usr/bin/env sh

BLU_CNT_CONTROLLER=$(ls -1q /sys/class/bluetooth | wc -l)

if [[ $BLU_CNT_CONTROLLER -gt 0 ]]
then
    BLU_POWER=$(bluetoothctl show | grep -q 'Powered: yes$'; echo "$?")
    if [[ $BLU_POWER -eq 0 ]]
    then
        BLU_CONNECTED=$(bluetoothctl devices Connected | sed -n -e 's/^Device \([[:xdigit:]]\{1,2\}:\)\{5\}[[:xdigit:]]\{1,2\} //p')
        BLU_CONNECTED_MAC=$(bluetoothctl devices Connected | sed -n -e 's/^Device \(\([[:xdigit:]]\{1,2\}:\)\{5\}[[:xdigit:]]\{1,2\}\) .*/\1/p')
        if [[ $BLU_CONNECTED != "" ]]
        then
            echo " $BLU_CONNECTED |"
        else
            echo " |"
        fi
    else
        echo "󰂲 |"
    fi
else
    echo "󰂲 +  |"
fi
