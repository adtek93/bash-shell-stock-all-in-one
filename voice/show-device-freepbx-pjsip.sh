#!/bin/bash
# --------------------------------------------
# Script: show_sip_reg.sh
# Mục đích: Hiển thị danh sách SIP endpoint đang đăng ký
# Output: STT | endpoint | IP WAN | IP local | user_agent
# --------------------------------------------

# Lấy dữ liệu từ Asterisk database
DATA=$(asterisk -rx "database show registrar/contact" 2>/dev/null)

if [ -z "$DATA" ]; then
    echo "Không tìm thấy dữ liệu đăng ký SIP trong database."
    exit 1
fi

# In tiêu đề bảng
printf "%-4s | %-10s | %-15s | %-15s | %s\n" "STT" "Endpoint" "IP WAN" "IP Local" "User Agent"
printf "%-4s-+-%-10s-+-%-15s-+-%-15s-+-%s\n" "----" "----------" "---------------" "---------------" "-------------------------------------"

# Parse từng dòng JSON và in ra thông tin cần thiết
echo "$DATA" | grep -Eo '"endpoint":"[^"]+"|"uri":"[^"]+"|"via_addr":"[^"]+"|"user_agent":"[^"]+"' | \
awk -F'"' '
/"endpoint":/   {endpoint=$4}
/"via_addr":/   {ip_local=$4}
/"uri":/        {split($4, a, "@"); split(a[2], b, ":"); ip_wan=b[1]}
/"user_agent":/ {
    user_agent=$4
    count++
    printf "%-4d | %-10s | %-15s | %-15s | %s\n", count, endpoint, ip_wan, ip_local, user_agent
}'
