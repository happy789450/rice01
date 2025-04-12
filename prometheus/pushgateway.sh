#!/bin/bash
cd /srv/
wget https://github.com/prometheus/pushgateway/releases/download/v1.6.2/pushgateway-1.6.2.linux-amd64.tar.gz
tar xvf pushgateway-*.tar.gz

mv pushgateway  /usr/local/

# 在 prometheus.yml 中添加：
  - job_name: 'pushgateway'
    honor_labels: true  # 保留脚本推送的标签
    static_configs:
      - targets: ['localhost:9091']

systemctl restart prometheus


cat <EOF >> /usr/lib/systemd/system/pushgateway.service 
[Unit]
Description=Prometheus Pushgateway
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=always
RestartSec=5s

ExecStart=/usr/local/pushgateway/pushgateway --web.listen-address=:9091 --persistence.file=/var/lib/pushgateway/metrics.store

[Install]
WantedBy=multi-user.target
EOF
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir -p /var/lib/pushgateway
sudo chown -R prometheus:prometheus /var/lib/pushgateway
# 重载 systemd 配置
sudo systemctl daemon-reload
# 启动服务
sudo systemctl start pushgateway
# 设置开机自启
sudo systemctl enable pushgateway
# 检查状态
sudo systemctl status pushgateway

echo "然后去grafana 新建仪表盘"
