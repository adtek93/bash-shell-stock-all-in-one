#!/bin/bash
#set -e

# Update hệ thống
#apt update -y
#apt upgrade -y

# Cài đặt các gói cần thiết
#apt install -y build-essential git wget vim net-tools \
#  libedit-dev uuid-dev libxml2-dev libsqlite3-dev \
#  libncurses5-dev libnewt-dev libssl-dev libjansson-dev \
#  libcurl4-openssl-dev libgsm1-dev libogg-dev libvorbis-dev \
#  libspeex-dev libspeexdsp-dev libasound2-dev libcurl4-openssl-dev \
#  libspandsp-dev libiksemel-dev libgmime-3.0-dev subversion \
#  sox autoconf automake libtool-bin pkg-config unixodbc-dev

# Tắt SELinux (Debian mặc định không có SELinux, nên chỉ echo)
#echo "SELinux không bật trên Debian, bỏ qua bước này."

# Tải và giải nén Asterisk
#cd /usr/src/
#wget https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
#tar xvf asterisk-*
#cd asterisk-*

# Cài đặt các script phụ thuộc
contrib/scripts/install_prereq install

# Cấu hình và build
./configure --with-pjproject-bundled --with-jansson-bundled
contrib/scripts/get_mp3_source.sh
make menuselect
make
make install
make samples
make config
ldconfig

# Tự khởi động dịch vụ khi boot
systemctl enable asterisk
systemctl start asterisk

echo "✅ Cài đặt Asterisk trên Debian 11 hoàn tất!"
