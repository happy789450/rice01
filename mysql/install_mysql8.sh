#!/bin/bash

cd /srv
wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
sudo yum localinstall mysql80-community-release-el7-3.noarch.rpm

sudo yum install -y mysql-community-server --nogpgcheck
sudo systemctl start mysqld
sudo systemctl enable mysqld

sudo grep 'temporary password' /var/log/mysqld.log
tmp_pass=$(grep 'temporary password' /var/log/mysqld.log  | awk '{print $NF}' | tail -1)

yum -y install expect

expect ./mysql/change_ps8.sh



cat <<EOF >>/etc/my.cnf
validate_password.policy=low
validate_password.length=6
EOF

systemctl restart mysqld
systemctl status mysqld

echo "mysql8 密码策略修改成功"
