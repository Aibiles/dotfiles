#!/bin/bash

PPPOE="PPPoE"
HOTSPOT="Hotspot"
WIFI="wlp3s0"

SSID="Mimsy-404"
PASSWORD="44444444"

case "$1" in
    on)
        echo "断开 Wi-Fi..."
        nmcli device disconnect "$WIFI"

        echo "正在 PPPoE 拨号..."
        nmcli connection up "$PPPOE" || {
            echo "PPPoE 拨号失败，恢复 Wi-Fi..."
            nmcli device connect "$WIFI"
            exit 1
        }

        echo "正在创建热点..."

        # 清理可能残留的旧配置
        nmcli connection delete "$HOTSPOT" 2>/dev/null

        # 创建热点
        nmcli connection add \
            type wifi \
            ifname "$WIFI" \
            con-name "$HOTSPOT" \
            ssid "$SSID"

        if [ $? -ne 0 ]; then
            echo "热点配置创建失败"
            nmcli connection down "$PPPOE"
            nmcli device connect "$WIFI"
            exit 1
        fi

        # 配置 AP 模式、共享网络和密码
        nmcli connection modify "$HOTSPOT" \
            802-11-wireless.mode ap \
            802-11-wireless.band bg \
            ipv4.method shared \
            ipv6.method disabled \
            wifi-sec.key-mgmt wpa-psk \
            wifi-sec.psk "$PASSWORD"

        echo "正在开启热点..."

        nmcli connection up "$HOTSPOT" || {
            echo "热点开启失败"
            nmcli connection delete "$HOTSPOT"
            nmcli connection down "$PPPOE"
            nmcli device connect "$WIFI"
            exit 1
        }

        echo "热点已开启"
        echo "SSID: $SSID"
        ;;

    off)
        echo "关闭热点..."
        nmcli connection down "$HOTSPOT" 2>/dev/null

        echo "删除热点配置..."
        nmcli connection delete "$HOTSPOT" 2>/dev/null

        echo "断开 PPPoE..."
        nmcli connection down "$PPPOE" 2>/dev/null

        echo "恢复 Wi-Fi..."
        nmcli device connect "$WIFI"

        echo "已恢复正常 Wi-Fi"
        ;;

    status)
        CLIENTS=$(ip neigh show dev "$WIFI" 2>/dev/null |
            awk '$NF != "FAILED" {print $1 "  " $5}')

        [ -z "$CLIENTS" ] && CLIENTS="无设备连接"

        notify-send \
            -t 5000 \
            "热点设备" \
            "$CLIENTS"
        ;;
esac
