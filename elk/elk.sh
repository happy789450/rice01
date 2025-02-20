# CentOS 7 安装 ELK (Elasticsearch, Logstash, Kibana) 的步骤如下：
# 安装Java：
# ELK stack依赖Java，所以首先安装Java。
sudo yum -y install java-1.8.0-openjdk

# 安装Elasticsearch：
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
echo '[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md' | sudo tee /etc/yum.repos.d/elasticsearch.repo
 
sudo yum -y  install elasticsearch
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch

# 安装Kibana：
echo '[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md' | sudo tee /etc/yum.repos.d/kibana.repo
 
sudo yum -y install kibana
sudo systemctl start kibana
sudo systemctl enable kibana

# 安装Logstash：
echo '[logstash-7.x]
name=Logstash repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md' | sudo tee /etc/yum.repos.d/logstash.repo
 
yum -y install logstash
systemctl start logstash
systemctl enable logstash
systemctl status logstash

# 安装filebeat
yum -y install filebeat
systemctl start filebeat
systemctl enable filebeat
systemctl status filebeat

echo "下面查看文件手动操作,脚本退出"
exit 2
