#!/bin/bash

status=$(playerctl status 2>/dev/null)

if [ "$status" = "Playing" ]; then
    icon=""
elif [ "$status" = "Paused" ]; then
    icon=""
else
    exit
fi

artist=$(playerctl metadata artist)
title=$(playerctl metadata title)

echo "$artist - $title"
