#!/bin/bash
# node 服务器安装 node_exporter
cd /srv/
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar -xf  node_exporter-1.3.1.linux-amd64.tar.gz
mv node_exporter-1.3.1.linux-amd64  /usr/local/node_exporter

# 添加systemctl 启动
cat <<EOF >>/usr/lib/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
ExecStart=/usr/local/node_exporter/node_exporter
User=root
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start  node_exporter.service
systemctl enable  node_exporter.service
systemctl status node_exporter.service
# 默认端口号是 9100
ss -utnlp | grep 9100
