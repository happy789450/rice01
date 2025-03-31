#!/bin/bash
# 通过 containerd启动 k8s集群master操作
# 以下指令适用于 Kubernetes 1.28.2。
hostname=$(hostname)
master_ip=$(ifconfig | egrep -A 1 "ens33:|eth0:" | grep inet | awk '{print $2}')

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
modprobe br-netfilter
# 开启IPVS
yum install ipset ipvsadm -y
cat >> /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash

ipvs_modules="ip_vs ip_vs_lc ip_vs_wlc ip_vs_rr ip_vs_wrr ip_vs_lblc ip_vs_lblcr ip_vs_dh ip_vs_vip ip_vs_sed ip_vs_ftp nf_conntrack"

for kernel_module in $ipvs_modules; 
do
        /sbin/modinfo -F filename $kernel_module >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                /sbin/modprobe $kernel_module
        fi
done

chmod 755 /etc/sysconfig/modules/ipvs.modules
EOF

bash /etc/sysconfig/modules/ipvs.modules


# 安装containerd 
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
sed -i "s#SystemdCgroup\ \=\ false#SystemdCgroup\ \=\ true#g" /etc/containerd/config.toml
sudo systemctl restart containerd

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
echo " 初始化命令"
echo "
kubeadm init \
--apiserver-advertise-address=$master_ip \
--cri-socket=unix:///var/run/containerd/containerd.sock \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version $kube_version \
--service-cidr=10.1.0.0/16 \
--pod-network-cidr=10.244.0.0/16 " | bash 

#配置kubectl 工具
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# 安装calico
# kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f ./yml/calico.yaml
