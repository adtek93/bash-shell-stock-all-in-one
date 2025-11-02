#!/bin/bash
set -e

# ==== Kiểm tra quyền root ====
if [ "$(id -u)" -ne 0 ]; then
  echo "⚠️  Vui lòng chạy bằng root hoặc sudo."
  exit 1
fi

echo "=== Bắt đầu nâng cấp Debian 11 -> Debian 12 ==="

# ==== Bước 1: Cập nhật hệ thống hiện tại ====
echo "[1/5] Update hệ thống Debian 11"
apt update && apt -y upgrade && apt -y full-upgrade
apt -y --purge autoremove

# ==== Bước 2: Backup sources.list ====
echo "[2/5] Backup /etc/apt/sources.list"
cp /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +%F)

# ==== Bước 3: Chuyển 'bullseye' thành 'bookworm' ====
echo "[3/5] Sửa sources.list sang bookworm"
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list

# Nếu có file trong /etc/apt/sources.list.d, bạn cần tự chỉnh sửa tương tự
echo "⚠️  Kiểm tra thủ công /etc/apt/sources.list.d/* nếu có repo ngoài."

# ==== Bước 4: Update và dist-upgrade ====
echo "[4/5] Update repository mới"
apt update

echo "[5/5] Thực hiện dist-upgrade"
apt -y upgrade
apt -y full-upgrade

# ==== Hoàn tất ====
echo "🎉 Hoàn tất nâng cấp. Khuyến nghị reboot ngay."
echo "Chạy: reboot"
