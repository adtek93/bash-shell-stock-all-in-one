#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

DOMAIN="your-domain"
CURRENT_IP=$(dig +short $DOMAIN | tail -n1)
IP_FILE="/root/current_ip.txt"

# Nếu chưa có file, tạo file rỗng
[ ! -f "$IP_FILE" ] && echo "" > "$IP_FILE"

OLD_IP=$(cat $IP_FILE)

if [ "$CURRENT_IP" != "$OLD_IP" ] && [ -n "$CURRENT_IP" ]; then
    echo "$(date) - IP thay đổi: $OLD_IP -> $CURRENT_IP"

    # Xóa toàn bộ rule chứa IP cũ
    if [ -n "$OLD_IP" ]; then
        iptables -L INPUT --line-numbers -n | grep "$OLD_IP" | \
        awk '{print $1}' | sort -rn | while read NUM; do
            iptables -D INPUT $NUM
        done
    fi

    # Thêm rule mới cho IP hiện tại
    for PORT in 9100 9256 80 443 22666; do
        iptables -I INPUT -p tcp -s "$CURRENT_IP" --dport $PORT -j ACCEPT
    done

    # Chặn toàn bộ truy cập khác
    for PORT in 9100 9256 80 443 22666; do
        # Xóa DROP cũ nếu có
        while iptables -C INPUT -p tcp --dport $PORT -j DROP 2>/dev/null; do
            iptables -D INPUT -p tcp --dport $PORT -j DROP
        done
        iptables -A INPUT -p tcp --dport $PORT -j DROP
    done

    # Ghi lại IP mới
    echo "$CURRENT_IP" > "$IP_FILE"
else
    echo "$(date) - IP chưa thay đổi ($CURRENT_IP)"
fi
