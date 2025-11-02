#!/bin/bash
# ==========================================
# Script tạo swap 1GB cho Debian/Ubuntu
# ==========================================

SWAPFILE="/swapfile"
SWAPSIZE="1G"

echo ">>> Tạo file swap $SWAPFILE dung lượng $SWAPSIZE ..."

# Kiểm tra xem đã có swap chưa
if swapon --show | grep -q "$SWAPFILE"; then
  echo ">>> Swap đã tồn tại, bỏ qua."
  exit 0
fi

# Tạo file swap
fallocate -l $SWAPSIZE $SWAPFILE || dd if=/dev/zero of=$SWAPFILE bs=1M count=1024
chmod 600 $SWAPFILE
mkswap $SWAPFILE
swapon $SWAPFILE

# Thêm vào fstab nếu chưa có
if ! grep -q "$SWAPFILE" /etc/fstab; then
  echo "$SWAPFILE none swap sw 0 0" >> /etc/fstab
  echo ">>> Đã thêm vào /etc/fstab"
fi

# Thiết lập kernel optimization
echo ">>> Cấu hình kernel swappiness và cache pressure..."
sysctl -w vm.swappiness=10
sysctl -w vm.vfs_cache_pressure=50

# Ghi vĩnh viễn
grep -q "vm.swappiness" /etc/sysctl.conf || echo "vm.swappiness=10" >> /etc/sysctl.conf
grep -q "vm.vfs_cache_pressure" /etc/sysctl.conf || echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf

# Kiểm tra kết quả
echo ">>> Kết quả sau khi tạo:"
free -m
swapon --show

echo ">>> Hoàn tất! Swap $SWAPSIZE đã được kích hoạt vĩnh viễn."
