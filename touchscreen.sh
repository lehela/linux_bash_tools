#!/bin/bash
# set -x

OK=NO
ID=$(xinput list --id-only "ELAN Touchscreen")
CMD=$1
STATUS=$(xinput --list-props $ID|grep "Device Enabled")
STATUS=${STATUS: -1}


if [[ $CMD == "toggle" ]]
then
	if [[ $STATUS == 1 ]]
	then
		CMD=stop
	else
		CMD=start
	fi
fi

if [[ $CMD == "start" ]]
then
        xinput enable $ID
        touchscreen.sh status
        OK=YES
fi

if [[ $CMD == "stop" ]]
then
        xinput disable $ID
        touchscreen.sh status
        OK=YES
fi

if [[ $CMD == "status" ]]
then
	if [[ $STATUS == 1 ]]
	then
		ICON=dialog-information
		MSG=Active
	else
		ICON=dialog-error
		MSG=Off
	fi
        xinput --list-props $ID |grep "Device"
	notify-send -i $ICON 'Touchscreen Status' $MSG
        OK=YES
fi

if [[ $OK == "NO" ]] 
then
        echo Usage: touchscreen.sh \[start\|stop\|status\]
fi

