#!/bin/bash

target="${1:-primary}"

text=$(
    xclip -o -selection "$target" \
    | xargs
)

[ -z "$text" ] && exit

# 判断是不是单词
if [[ "$text" =~ ^[A-Za-z-]+$ ]]; then
    result="$text\n\n$(sdcv -n "$text" | head -30)"
else
    translated=$(
        trans -proxy 127.0.0.1:7897 \
          -b :zh "$text" \
        | fold -s -w 110
    )
    result="$text\n\n$translated"
fi

echo -e "$result" | \
rofi -dmenu \
-i \
-no-custom \
-p "Translate" \
-config ~/.config/rofi/config.rasi
