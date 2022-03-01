#!/bin/bash

hostname=$(hostname)
master_ip=$(ifconfig |awk 'NR==2{print $2}')

#关闭防火墙
systemctl stop firewalld 
systemctl disable firewalld 

#关闭swap分区
swapoff -a

#永久关闭swap
sed -i '/swap/ s/^/#/g' /etc/fstab

echo -e  "$master_ip  \t$hostname"  >> /etc/hosts


#配置内核参数，将桥接的IPv4流量传递到iptables的链
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

#安装docker
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O/etc/yum.repos.d/docker-ce.repo
yum -y install docker-ce-18.06.1.ce-3.el7

#更改docker的启动参数
sed -i  's/ExecStart=\/usr\/bin\/dockerd /ExecStart=\/usr\/bin\/dockerd --exec-opt native.cgroupdriver=systemd/g'  /usr/lib/systemd/system/docker.service

systemctl daemon-reload
systemctl restart docker



#添加阿里kubernetes源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum -y  install kubectl kubelet kubeadm --nogpgcheck
systemctl enable kubelet

#这里不用启动kubelet  会报错

#初始化k8s集群
#kubeadm init --kubernetes-version=1.18.0  \
#--apiserver-advertise-address=192.168.122.21   \
#--image-repository registry.aliyuncs.com/google_containers  \
#--service-cidr=10.10.0.0/16 --pod-network-cidr=10.122.0.0/16
