#!/bin/bash

fstCmd=""
failCmd=""

state=0
while [ ! -z "$1" ]; do
	if [ "$1" = "--" ] && [ $state -eq 0 ]; then
		state=1
	else
		if [ $state -eq 0 ]; then
			fstCmd="$fstCmd $1"
		else
			failCmd="$failCmd $1"
		fi
	fi
	shift
done

eval "$fstCmd"
exc=$?
if [ $exc -ne 0 ]; then
	eval "$failCmd"
fi
	exit $exc

