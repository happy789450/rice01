#!/bin/bash

hostname=$(hostname)
node_ip=$(ifconfig |awk 'NR==2{print $2}')

#关闭防火墙
systemctl stop firewalld 
systemctl disable firewalld 

#关闭swap分区
swapoff -a

#永久关闭swap
sed -i '/swap/ s/^/#/g' /etc/fstab

echo -e  "$node_ip  \t$hostname"  >> /etc/hosts
echo -e  "$node_ip  \t$node"  >> /etc/hosts


#配置内核参数，将桥接的IPv4流量传递到iptables的链
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

#安装docker
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O/etc/yum.repos.d/docker-ce.repo
# yum -y install docker-ce-18.06.1.ce-3.el7
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#更改docker的启动参数
sed -i  's/ExecStart=\/usr\/bin\/dockerd/ExecStart=\/usr\/bin\/dockerd --exec-opt native.cgroupdriver=systemd/g'  /usr/lib/systemd/system/docker.service

systemctl daemon-reload
systemctl restart docker
systemctl enable docker 

# 若没有wget，则执行
yum install -y wget
# 下载
cd /srv
wget https://gitee.com/rice01/linux/raw/master/cri-dockerd-0.3.4-3.el7.x86_64.rpm
# 安装
rpm -ivh cri-dockerd-0.3.4-3.el7.x86_64.rpm
# 重载系统守护进程

sed -i 's/--container-runtime-endpoint fd:\/\//--network-plugin=cni --pod-infra-container-image=registry.aliyuncs.com\/google_containers\/pause:3.7/g'   /usr/lib/systemd/system/cri-docker.service

systemctl daemon-reload


tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://c12xt3od.mirror.aliyuncs.com"]
}
EOF




# 重载系统守护进程
sudo systemctl daemon-reload
# 设置cri-dockerd自启动
sudo systemctl enable cri-docker.socket cri-docker
# 启动cri-dockerd
sudo systemctl start cri-docker.socket cri-docker
# 检查Docker组件状态
sudo systemctl status docker cir-docker.socket cri-docker



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
#提前拉取镜像  不然初始化的时候会等很久 也有可能失败
# kubeadm config images pull

##初始化k8s集群
#kubeadm init \
#--apiserver-advertise-address=$master_ip \
#--image-repository registry.aliyuncs.com/google_containers \
#--kubernetes-version v1.23.4 \
#--service-cidr=10.1.0.0/16 \
#--pod-network-cidr=10.244.0.0/16
#
##配置kubectl 工具
#mkdir -p $HOME/.kube
#cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#chown $(id -u):$(id -g) $HOME/.kube/config

#成功之后 执行kubeadm join 命令  命令参数 在master init之后会生成

echo "请查看k8s.txt 把master scp /etc/kubernetes/admin.conf 192.168.255.141:/etc/kubernetes/ 拷贝到node节点 然后source"

#安装pod网络插件
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
