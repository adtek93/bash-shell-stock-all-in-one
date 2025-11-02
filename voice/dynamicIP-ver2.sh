#!/bin/bash

# Đường dẫn tệp lưu IP hiện tại
ipcheck_file="/etc/asterisk/PBX/ipcheck.txt"

# Lấy IP hiện tại từ tên miền
ipcheck=$(host your-domain | awk 'NR==1{print $4}')

# Kiểm tra nếu tệp tồn tại, nếu không, tạo tệp
if [ ! -f "$ipcheck_file" ]; then
    echo "$ipcheck" > "$ipcheck_file"
    echo "First run, IP saved: $ipcheck"
    exit 0
fi

# Lấy IP lưu trước đó
ipcheck_query=$(cat "$ipcheck_file")

# So sánh IP
if [ "$ipcheck_query" = "$ipcheck" ]; then
    echo "$ipcheck - IP Similar, no changes."
else
    echo "$ipcheck" > "$ipcheck_file"
    echo "IP updated to: $ipcheck"
cat > /etc/asterisk/PBX/trunking_VIP172.20.10.254.conf << EOF


[PBX1]
type=peer
qualify=yes
insecure=port,invite
canreinvite=no
host=$ipcheck
port=
context=FromFreePBX
disallow=all
allow=ulaw
allow=alaw
deny=0.0.0.0/0.0.0.0
permit=$ipcheck/255.255.255.255

EOF

cat > /etc/asterisk/pjsip_custom.conf << EOF
[FPBX]
type=aor
qualify_frequency=15
contact=sip:$ipcheck:port
max_contacts=1

[FPBX]
type=endpoint
transport=0.0.0.0-udp
context=From-FPBX25
disallow=all
allow=g722,ulaw,alaw,opus
aors=FPBX-25
send_connected_line=no
rtp_keepalive=0
language=en
user_eq_phone=no
t38_udptl=no
t38_udptl_ec=none
fax_detect=no
trust_id_inbound=no
t38_udptl_nat=no
direct_media=no
rtp_symmetric=yes
dtmf_mode=auto

[FPBX]
type=identify
endpoint=FPBX
match=$ipcheck/32
EOF

/usr/sbin/asterisk -rx "core reload"
echo "UpdateSuccess!"
fi
