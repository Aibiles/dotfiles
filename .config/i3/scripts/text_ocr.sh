#!/bin/bash
lang=$(printf "en\nzh\nzh_tw\njp\nzh_en\nzh_jp" | \
    rofi -dmenu -p "OCR:" -config ~/.config/rofi/translate.rasi
  )

case "$lang" in
    "en")
        tess_lang="eng"
        ;;
    "zh")
        tess_lang="chi_sim"
        ;;
    "zh_tw")
        tess_lang="chi_tra"
        ;;
    "jp")
        tess_lang="jpn"
        ;;
    "zh_en")
        tess_lang="chi_sim+eng"
        ;;
    "zh_jp")
        tess_lang="chi_sim+jpn"
        ;;
    *)
        exit 0
        ;;
esac

tmp=$(mktemp --tmpdir=/dev/shm ocr.XXXXXX.png)
txt=$(mktemp --tmpdir=/dev/shm ocr.XXXXXX.txt)

# 截图
maim -s "$tmp" || {
    rm -f "$tmp"
    exit 1
}

# OCR
text=$(tesseract "$tmp" stdout -l "$tess_lang" 2>/dev/null)
tesseract "$tmp" stdout -l "$tess_lang" > "$txt" 2>/dev/null

# 编辑 OCR 结果
xed "$txt"

# 复制修改后的内容
xclip -selection clipboard < "$txt"

notify-send "OCR完成" "修改后的文本已复制"

rm -f "$tmp" "$txt"
rm -f "$tmp"
