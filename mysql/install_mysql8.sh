#!/bin/bash

cd /srv
wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
sudo yum localinstall mysql80-community-release-el7-3.noarch.rpm

sudo yum install mysql-community-server --nogpgcheck
sudo systemctl start mysqld
sudo systemctl enable mysqld

sudo grep 'temporary password' /var/log/mysqld.log
tmp_pass=$(grep 'temporary password' /var/log/mysqld.log  | awk '{print $NF}' | tail -1)

mysql -uroot -p$tmp_pass -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass123!';"
mysql -uroot -pMyNewPass123! -e "SET GLOBAL validate_password.policy = 'LOW';"
mysql -uroot -pMyNewPass123! -e "SET GLOBAL validate_password.length = 6;"
mysql -uroot -pMyNewPass123! -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';"

cat <<EOF >>/etc/my.cnf
validate_password.policy=low
validate_password.length=6
EOF

systemctl restart mysqld
systemctl status mysqld

echo "mysql8 密码策略修改成功"
