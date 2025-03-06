#!/bin/bash
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# 下面2步需要代理
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y containerd.io
sudo systemctl enable --now containerd
sudo systemctl status containerd

# 生成默认配置文件：
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# 编辑配置文件（可选）：
# sudo vim /etc/containerd/config.toml

##安装 runc
#cd /srv/
#wget https://github.com/opencontainers/runc/releases/download/v1.1.7/runc.amd64
## 安装
#install -m 755 runc.amd64 /usr/local/bin/runc
## 验证
#runc -v

