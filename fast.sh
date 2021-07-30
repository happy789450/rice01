#!/bin/bash
#执行就对了
read -p "请选择要做的事
1，初始化（安装vim等）					10,安装测试网速软件	
2，安装nginx						11,安装jenkins
3，安装mysql5.7						12,安装shadowsocks
4, 安装php7.2
5, 安装zabbix
6，一键安装nginx,mysql,php,zabbix
7, 安装redis
8, 安装zabbix-agent
9, 安装rabbitmq				
0, 查看脚本说明
请选择要做的事:" choice
echo 

function install_vim(){
  yum -y install vim net-tools  wget  git bash-completion make bind-utils gcc m4 autoconf unzip zip lrzsz
  mkdir /root/srv/
}


function install_nginx(){
  yum -y install pcre pcre-devel openssl-devel openssl gcc gcc-c++
  mkdir /root/srv/ ; cd /root/srv/
  wget http://www.rice666.com:8888/nginx-1.16.1.tar.gz
  useradd -s /sbin/nologin -M nginx
  tar -xf nginx-1.16.1.tar.gz
  cd /root/srv/nginx-1.16.1
  ./configure --prefix=/usr/local/nginx --user=nginx --group=nginx  --with-http_stub_status_module --with-http_ssl_module --with-stream
  make && make install 
  ln -s /usr/local/nginx/sbin/nginx /bin/nginx
  echo nginx is ok > /usr/local/nginx/html/index.html
  sed -i '116a include /usr/local/nginx/conf/conf.d/*.conf;' /usr/local/nginx/conf/nginx.conf
  mkdir /usr/local/nginx/conf/conf.d/
  /usr/local/nginx/sbin/nginx
  ps -ef |grep nginx
  echo nginx 已启动
}

function install_mysql(){
  read -p "请输入新的mysql密码:" new_mysql_pass
  read -p "请再次输入新的mysql密码:" new_mysql_pass2
if [ $new_mysql_pass == $new_mysql_pass2  ];then
  systemctl stop mysqld mariadb
  cd /root/srv/
  wget http://repo.mysql.com/mysql57-community-release-el7-9.noarch.rpm
  rpm -ivh mysql57-community-release-el7-9.noarch.rpm
  yum -y  install mysql mysql-server mysql-devel
  rm -f /etc/my.cnf
  cd /root/srv/
  wget http://www.rice666.com:8888/my.cnf
  \cp  /root/srv/my.cnf  /etc/my.cnf
  chown mysql:mysql /etc/my.cnf
  rm -rf /var/lib/mysql
  echo ""  > /var/log/mysqld.log
  chown mysql:mysql /var/log/mysqld.log
  systemctl start mysqld  && systemctl enable mysqld
  mysql_pass=$(grep "temporary password"  /var/log/mysqld.log  | awk '{print $NF}')
  mysql -uroot -p"$mysql_pass"  --connect-expired-password -e "set global validate_password_policy=0;"
  mysql -uroot -p"$mysql_pass"  --connect-expired-password -e "set global validate_password_length=1;"
  mysql -uroot -p"$mysql_pass"  --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$new_mysql_pass';"
  echo validate_password_policy=0 >>/etc/my.cnf
  echo validate_password_length=1 >>/etc/my.cnf
  systemctl restart mysqld  && systemctl status mysqld
  echo "新的mysql密码是$new_mysql_pass" >> /root/.mysql_history
  echo "已将密码追加到/root/.mysql_history,如忘记可查看"
else
  install_mysql
fi  
}

function install_php7(){
  yum install -y gcc gcc-c++  make zlib zlib-devel pcre pcre-devel  libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers libxslt libxslt-devel
  mkdir /root/srv/ ; cd /root/srv
  wget http://www.rice666.com:8888/php-7.2.19.tar.gz
  tar -xf php-7.2.19.tar.gz
  cd php-7.2.19/
  ./configure --prefix=/usr/local/php7 --with-config-file-path=/usr/local/php7/etc --with-curl --with-mhash --with-gd --with-gettext --with-iconv-dir --with-kerberos --with-ldap --with-libdir=lib64 --with-libxml-dir --with-openssl --with-pcre-regex --with-pdo-sqlite --with-pear --with-xmlrpc --with-xsl --with-zlib --enable-fpm --enable-ldap --enable-bcmath --enable-libxml --enable-inline-optimization --enable-mbregex --enable-mbstring --enable-opcache --enable-pcntl --enable-shmop --enable-soap --enable-sockets --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-xml --enable-zip --enable-static --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-freetype-dir --with-jpeg-dir --with-png-dir --disable-debug
  make && make install
  echo "PATH=$PATH:/usr/local/php7/bin"  >> /etc/profile
  echo "export PATH"  >> /etc/profile
  source /etc/profile
  cp /usr/local/php7/etc/php-fpm.conf.default  /usr/local/php7/etc/php-fpm.conf
  cp /usr/local/php7/etc/php-fpm.d/www.conf.default  /usr/local/php7/etc/php-fpm.d/www.conf
  cp /root/srv/php-7.2.19/php.ini-production   /usr/local/php7/etc/php.ini 
  sed -i  '18a pid = run/php-fpm.pid'  /usr/local/php7/etc/php-fpm.conf
  sed -i '942c date.timezone = Asia/Shanghai' /usr/local/php7/etc/php.ini
  sed -i '385c max_execution_time = 300' /usr/local/php7/etc/php.ini
  sed -i '674c post_max_size = 32M'  /usr/local/php7/etc/php.ini
  sed -i '395c max_input_time = 300' /usr/local/php7/etc/php.ini
  cd /root/srv/ 
  wget http://www.rice666.com:8888/systemctl/php-fpm.service
  cd /root/srv
  cp /root/srv/php-fpm.service /usr/lib/systemd/system/php-fpm.service
  systemctl daemon-reload 
  systemctl start php-fpm && systemctl enable php-fpm
}

function install_zabbix(){
  read -p "请输入数据库密码:" mysql_passwd
  read -p "请再次输入数据库密码:" mysql_passwd2
if [ $mysql_pass == $mysql_pass2  ];then
  yum -y install net-snmp-devel curl-devel libevent-devel
  mkdir /root/srv ;  cd /root/srv/
  wget https://cdn.zabbix.com/zabbix/sources/stable/5.2/zabbix-5.2.0.tar.gz
  tar -xf zabbix-5.2.0.tar.gz
  cd /root/srv/zabbix-5.2.0
  ./configure --prefix=/usr/local/zabbix --enable-server --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2
  cd /root/srv/zabbix-5.2.0/
  make && make install
  mysql -uroot -p$mysql_passwd <<EOF 
create database zabbix character set utf8 collate utf8_bin;
grant all on zabbix.* to zabbix@"localhost" identified by "zabbix";
EOF
  cd /root/srv/zabbix-5.2.0/database/mysql/
  mysql -uzabbix -pzabbix zabbix < schema.sql
  mysql -uzabbix -pzabbix zabbix < images.sql
  mysql -uzabbix -pzabbix zabbix < data.sql
  cp -a /root/srv/zabbix-5.2.0/ui/* /usr/local/nginx/html/
  cd /root/srv
  wget  http://www.rice666.com:8888/conf/simhei.ttf
  \cp  /root/srv/simhei.ttf    /usr/local/nginx/html/zabbix/assets/fonts/DejaVuSans.ttf
  chown -R nginx:nginx /usr/local/nginx/html
  useradd zabbix
  sed -i '118c DBPassword=zabbix' /usr/local/zabbix/etc/zabbix_server.conf
  sed -i '133c DBPort=3306' /usr/local/zabbix/etc/zabbix_server.conf
  cd /root/srv
  wget http://www.rice666.com:8888/systemctl/zabbix-server.service
  wget http://www.rice666.com:8888/systemctl/zabbix-agent.service
  cp /root/srv/zabbix-server.service /usr/lib/systemd/system/zabbix-server.service 
  cp /root/srv/zabbix-agent.service /usr/lib/systemd/system/zabbix-agent.service
  systemctl daemon-reload
  systemctl start zabbix-server && systemctl status zabbix-server
  systemctl start zabbix-agent && systemctl status zabbix-agent
  wget http://www.rice666.com:8888/conf/zabbix.conf
  cp zabbix.conf  /usr/local/nginx/conf/conf.d/
else
  install_zabbix
fi
}

function install_zabbix_agent(){
  yum -y install net-snmp-devel curl-devel libevent-devel
  cd /srv/
  wget https://cdn.zabbix.com/zabbix/sources/stable/4.0/zabbix-4.0.31.tar.gz
  tar -xf zabbix-4.0.31.tar.gz
  cd /srv/zabbix-4.0.31
  ./configure --prefix=/usr/local/zabbix --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2
  make && make install
  useradd zabbix
  cd /srv/
  wget http://www.rice666.com:8888/systemctl/zabbix-server.service
  wget http://www.rice666.com:8888/systemctl/zabbix-agent.service
  cp /srv/zabbix-agent.service /usr/lib/systemd/system/zabbix-agent.service
  systemctl daemon-reload
  systemctl start zabbix-agent && systemctl status zabbix-agent
}

function install_redis(){
    mkdir /root/srv/
    cd /root/srv/
    wget   http://download.redis.io/releases/redis-5.0.6.tar.gz
    tar -xf redis-5.0.6.tar.gz
    cd redis-5.0.6
    make MALLOC=libc
    make install PREFIX=/usr/local/redis
    cp /root/srv/redis-5.0.6/redis.conf  /usr/local/redis/bin/
    wget http://www.rice666.com:8888/systemctl/redis.service
    cp redis.service /usr/lib/systemd/system/redis.service
    sed -i '136c  daemonize yes'  /usr/local/redis/bin/redis.conf
    ln -s /usr/local/redis/bin/redis-cli /usr/bin/redis-cli
    systemctl daemon-reload
    systemctl start redis.service && systemctl status redis
}

function install_rabbitmq(){
    yum -y install gcc glibc-devel make ncurses-devel openssl-devel xmlto perl wget gtk2-devel binutils-devel
    mkdir /root/srv/
    cd /root/srv
    wget http://erlang.org/download/otp_src_22.0.tar.gz
    wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.0/rabbitmq-server-generic-unix-latest-toolchain-3.8.0.tar.xz
    tar -zxvf otp_src_22.0.tar.gz
    tar -xf rabbitmq-server-generic-unix-latest-toolchain-3.8.0.tar.xz
    cp -r rabbitmq_server-3.8.0/  /usr/local/rabbitmq
    cd otp_src_22.0
    ./configure --prefix=/usr/local/erlang
    make install 
    echo 'export PATH=$PATH:/usr/local/erlang/bin' >> /etc/profile
    echo 'export PATH=$PATH:/usr/local/rabbitmq/sbin' >> /etc/profile
    source /etc/profile
    rabbitmq-server -detached
    rabbitmq-plugins enable rabbitmq_management


}

function install_speedtest(){
    mkdir /root/srv
    cd /root/srv
    wget https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
    chmod +x speedtest.py
    mv speedtest.py /usr/local/bin/speedtest
    echo "直接执行speedtest即可测试网速"
}

function install_jenkins(){
    cd /srv/
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    yum -y install jenkins  java-1.8.0-openjdk
    systemctl start jenkins && systemctl enable jenkins &&systemctl status jenkins
    wget https://raw.githubusercontent.com/happy789450/rice01/main/conf/jenkins.conf
    echo "默认端口号8080,可以通过nginx代理访问"
}

function install_shadowsocks(){
    read -p "请输入密码:" shadow_pass
    read -p "请选择端口号:" shadow_port
    yum -y install python3
    pip3 install shadowsocks
    cd /srv/
    wget https://raw.githubusercontent.com/happy789450/rice01/main/systemctl/shadowsocks.service 
    wget https://raw.githubusercontent.com/happy789450/rice01/main/conf/shadowsocks.json
    mkdir /etc/shadowsocks
    cp shadowsocks.json  /etc/shadowsocks/shadowsocks.json
    cp shadowsocks.service  /usr/lib/systemd/system/ 
    sed -i "5c  \ \ \"$shadow_port\":\"$shadow_pass\"" /etc/shadowsocks/shadowsocks.json
    systemctl daemon-reload 
    systemctl start shadowsocks && systemctl enable shadowsocks &&systemctl shadowsocks jenkins 
    
}

function readme(){
  echo "本脚本尽量只执行一次，如果失败可以自行调整，少数服务可以多次执行无影响
        脚本有待完善
        通过改脚本安装的软件，大部分都支持通过systemctl启动
	nginx 重复安装需要删除/usr/local/nginx目录
	mysql可以重复安装
	安装zabbix-server里面包括agent，安装agent则没有server
	"
	

}


if   [ "$choice" = 1 ]; then
  install_vim 
elif [ "$choice" = 2 ];then
  install_nginx 
elif [ "$choice" = 3 ];then
  install_mysql 
elif [ "$choice" = 4 ];then
  install_php7
elif [ "$choice" = 5 ];then
  install_zabbix
elif [ "$choice" = 6 ];then
  install_vim
  install_nginx
  install_mysql
  install_php7
  install_zabbix
elif [ "$choice" = 7 ];then
  install_redis
elif [ "$choice" = 8 ];then
  install_zabbix_agent
elif [ "$choice" = 9 ];then
  install_rabbitmq
elif [ "$choice" = 10 ];then
  install_speedtest
elif [ "$choice" = 11 ];then
  install_jenkins
elif [ "$choice" = 12 ];then
  install_shadowsocks
elif [ "$choice" = 0 ];then
  readme
else
  echo "请重新输入" 
fi

