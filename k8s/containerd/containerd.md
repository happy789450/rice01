containerd 是一个高性能的容器运行时，提供了管理容器、镜像、快照等功能的命令行工具。以下是常用的 containerd 命令及其用法。
1. ctr 命令
ctr 是 containerd 的默认命令行工具，用于与 containerd 守护进程交互。以下是常用命令：

镜像管理
拉取镜像：
sudo ctr images pull docker.io/library/nginx:latest
列出本地镜像：
sudo ctr images list
删除镜像：
sudo ctr images remove docker.io/library/nginx:latest
导出镜像：
sudo ctr images export nginx.tar docker.io/library/nginx:latest
导入镜像：
sudo ctr images import nginx.tar
容器管理
创建容器：
sudo ctr run docker.io/library/nginx:latest my-nginx
列出容器：
sudo ctr containers list
启动容器：
sudo ctr task start my-nginx
查看容器任务：
sudo ctr tasks list
进入容器：
sudo ctr tasks exec -t --exec-id my-exec my-nginx bash
停止容器：
sudo ctr task kill my-nginx
删除容器：
sudo ctr containers delete my-nginx
命名空间管理
列出命名空间：
sudo ctr namespaces list
创建命名空间：
sudo ctr namespaces create my-namespace
删除命名空间：
sudo ctr namespaces delete my-namespace

快照管理
列出快照：
sudo ctr snapshots list
创建快照：
sudo ctr snapshots create my-snapshot
删除快照：
sudo ctr snapshots remove my-snapshot

2. containerd 服务管理
containerd 是一个守护进程，可以通过 systemctl 管理其服务。
启动 containerd：
sudo systemctl start containerd
停止 containerd：
sudo systemctl stop containerd
重启 containerd：
sudo systemctl restart containerd
查看 containerd 状态：
sudo systemctl status containerd
启用开机自启：
sudo systemctl enable containerd
禁用开机自启：
sudo systemctl disable containerd
