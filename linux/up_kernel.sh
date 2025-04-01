# 查找 kernel rpm 历史版本：http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/

# 下载内核 RPM
# 共需要下载三个类型 rpm  下载可能较慢

cd /srv/
wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-lt-devel-5.4.278-1.el7.elrepo.x86_64.rpm
wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-lt-headers-5.4.278-1.el7.elrepo.x86_64.rpm
wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-lt-5.4.278-1.el7.elrepo.x86_64.rpm
# 安装内核 
rpm -ivh kernel-lt-5.4.278-1.el7.elrepo.x86_64.rpm 
rpm -ivh kernel-lt-devel-5.4.278-1.el7.elrepo.x86_64.rpm
# 确认已安装内核版本
[root@ct7-6 linux]# rpm -qa | grep kernel
kernel-devel-3.10.0-1160.el7.x86_64
kernel-tools-libs-3.10.0-1160.el7.x86_64
abrt-addon-kerneloops-2.1.11-60.el7.centos.x86_64
kernel-headers-3.10.0-1160.el7.x86_64
kernel-lt-5.4.278-1.el7.elrepo.x86_64
kernel-3.10.0-1160.el7.x86_64
kernel-lt-devel-5.4.278-1.el7.elrepo.x86_64
kernel-tools-3.10.0-1160.el7.x86_64

# 查看启动顺序
[root@localhost ~]# awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg
CentOS Linux (5.4.278-1.el7.elrepo.x86_64) 7 (Core)
CentOS Linux (3.10.0-1160.el7.x86_64) 7 (Core)
CentOS Linux (0-rescue-1e535578571a4619a3d53036ca145737) 7 (Core)

# 设置启动顺序
[root@localhost ~]# grub2-set-default 0

# 重启生效
[root@localhost ~]# reboot

# 重启后查看
uname -a
