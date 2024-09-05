#!/bin/bash
# 以下指令适用于 Kubernetes 1.31。
hostname=$(hostname)
master_ip=$(ifconfig |awk 'NR==2{print $2}')

# 将 SELinux 设置为 permissive 模式：
setenforce 0
sed -i 's/^SELINUX=ENFORCING&/SELINUX=permissive/' /etc/selinux/config

# 关闭防火墙
systemctl stop firewalld 
systemctl disable firewalld 

#关闭swap分区
swapoff -a

#永久关闭swap
sed -i '/swap/ s/^/#/g' /etc/fstab

echo -e  "$master_ip  \t$hostname"  >> /etc/hosts
echo -e  "$master_ip  \tmaster"  >> /etc/hosts


#配置内核参数，将桥接的IPv4流量传递到iptables的链
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

#安装docker
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O/etc/yum.repos.d/docker-ce.repo

yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 若没有wget，则执行
sudo yum install -y wget
# 下载
cd /srv/
echo "cri-dockerd 软件较大，先下载"
sudo wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.4/cri-dockerd-0.3.4-3.el7.x86_64.rpm
# 安装
sudo rpm -ivh cri-dockerd-0.3.4-3.el7.x86_64.rpm
# 重载系统守护进程

sed -i  's/ExecStart=\/usr\/bin\/cri-dockerd/ExecStart=\/usr\/bin\/cri-dockerd --network-plugin=cni --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.7/g'  /usr/lib/systemd/system/cri-docker.service

sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://c12xt3od.mirror.aliyuncs.com"]
}
EOF



#更改docker的启动参数
#sed -i  's/ExecStart=\/usr\/bin\/dockerd/ExecStart=\/usr\/bin\/dockerd --exec-opt native.cgroupdriver=systemd/g'  /usr/lib/systemd/system/docker.service
sed -i  's/ExecStart=\/usr\/bin\/dockerd/ExecStart=\/usr\/bin\/dockerd --exec-opt native.cgroupdriver=systemd/g'  /usr/lib/systemd/system/docker.service

# 重载系统守护进程
sudo systemctl daemon-reload
# 设置cri-dockerd自启动
sudo systemctl enable cri-docker.socket cri-docker
# 启动cri-dockerd
sudo systemctl start cri-docker.socket cri-docker
# 检查Docker组件状态
sudo systemctl status docker cir-docker.socket cri-docker


## 添加yum源 版本1.31
#cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
#[kubernetes]
#name=Kubernetes
#baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
#enabled=1
#gpgcheck=1
#gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
#exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
#EOF

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
#yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable kubelet

#这里不用启动kubelet  会报错
# 提前拉取镜像  不然初始化的时候会等很久 也有可能失败
# kubeadm config images pull

kube_version=$(kubeadm version | awk -F '[: ]' '{print $9}'  | tr -d '",')

#初始化k8s集群
echo " 初始化命令
kubeadm init \
--apiserver-advertise-address=$master_ip \
--cri-socket=unix:///var/run/cri-dockerd.sock \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version $kube_version \
--service-cidr=10.1.0.0/16 \
--pod-network-cidr=10.244.0.0/16 "

#配置kubectl 工具
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

#安装pod网络插件
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
