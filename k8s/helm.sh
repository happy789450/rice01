#!/bin/bash
# 安装helm
cd /srv
wget https://get.helm.sh/helm-v3.11.3-linux-amd64.tar.gz
tar -zxvf helm-v3.11.3-linux-amd64.tar.gz
cd linux-amd64
sudo mv helm /usr/local/bin/
helm version
