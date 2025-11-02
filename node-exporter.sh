# Dành cho CentOS/Debian (tùy)
useradd -rs /bin/false node_exporter

wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
tar xvf node_exporter-1.8.1.linux-amd64.tar.gz
cd node_exporter-1.8.1.linux-amd64
cp node_exporter /usr/local/bin/

# Tạo systemd service
cat <<EOF | tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now node_exporter
