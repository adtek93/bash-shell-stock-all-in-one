#!/bin/bash
echo "🧹 Bắt đầu gỡ bỏ hoàn toàn Asterisk ..."

# 1. Dừng và vô hiệu hóa dịch vụ
echo "🔸 Dừng service Asterisk..."
systemctl stop asterisk 2>/dev/null
systemctl disable asterisk 2>/dev/null

# 2. Gỡ gói nếu cài qua apt
echo "🔸 Gỡ gói Asterisk (nếu có)..."
apt-get remove --purge -y asterisk* > /dev/null 2>&1
apt-get autoremove --purge -y > /dev/null 2>&1
apt-get autoclean -y > /dev/null 2>&1

# 3. Xóa thư mục cấu hình và dữ liệu
echo "🔸 Xóa thư mục cấu hình và dữ liệu..."
rm -rf /etc/asterisk
rm -rf /var/lib/asterisk
rm -rf /var/spool/asterisk
rm -rf /usr/lib/asterisk
rm -rf /usr/include/asterisk
rm -rf /var/log/asterisk
rm -rf /usr/src/asterisk*
rm -rf /opt/asterisk
rm -rf /run/asterisk

# 4. Xóa systemd service
echo "🔸 Xóa systemd service..."
rm -f /etc/systemd/system/asterisk.service
systemctl daemon-reload

# 5. Kiểm tra lại
echo "🔍 Kiểm tra trạng thái..."
if command -v asterisk >/dev/null 2>&1; then
    echo "⚠️  Asterisk vẫn còn trong PATH: $(which asterisk)"
else
    echo "✅ Asterisk đã được gỡ hoàn toàn khỏi hệ thống."
fi

echo "✨ Hoàn tất."
# 1. Dừng tiến trình Asterisk còn sót
pkill -9 asterisk 2>/dev/null

# 2. Xóa toàn bộ thư mục có thể chứa Asterisk
rm -rf /etc/asterisk
rm -rf /var/lib/asterisk
rm -rf /var/spool/asterisk
rm -rf /var/log/asterisk
rm -rf /usr/lib/asterisk
rm -rf /usr/include/asterisk
rm -rf /usr/src/asterisk*
rm -rf /opt/asterisk
rm -rf /run/asterisk
rm -rf /home/*/.asterisk*

# 3. Xóa các file build tạm, nếu có
find /usr/src -type d -name "asterisk*" -exec rm -rf {} +
find /tmp -type f -name "asterisk*" -delete

# 4. Xóa core dump (nếu có)
find / -type f -name "core.*" -delete

# 5. Xóa log lớn
journalctl --vacuum-time=1d

# 6. Dọn dẹp package rác
apt-get autoremove --purge -y
apt-get autoclean -y
apt-get clean -y

# 7. Kiểm tra dung lượng thư mục chính
du -sh /etc/asterisk /var/lib/asterisk /usr/lib/asterisk /usr/src/asterisk* 2>/dev/null
