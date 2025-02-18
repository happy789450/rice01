#!/bin/bash

cd /srv
wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
sudo yum localinstall mysql80-community-release-el7-3.noarch.rpm

sudo yum install mysql-community-server --nogpgcheck
sudo systemctl start mysqld
sudo systemctl enable mysqld

sudo grep 'temporary password' /var/log/mysqld.log
