#!/usr/bin/env bash

#!/bin/bash

# 杀死已有的 polybar 进程
killall -q polybar

# 等待进程完全关闭
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# 启动 bar
polybar --reload top &

echo "Bars launched..."
