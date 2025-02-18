#!/bin/bash
#执行就对了
read -p "请选择要做的事
1，初始化（安装vim等）					10,安装测试网速软件	
2，安装nginx						11,安装jenkins
3，安装mysql5.7						12,安装shadowsocks
4, 安装php8.2						13,安装node,npm
5, 安装zabbix						14,安装gitlab
6，一键安装nginx,mysql,php,zabbix			15,安装openresty+openstar
7, 安装redis						16,安装prometheus & grafana
8, 安装zabbix-agent
9, 安装rabbitmq				
0, 查看脚本说明
请选择要做的事:" choice

local_ip=$(ifconfig | egrep -A 1 "ens33:|eth0:" | grep inet | awk '{print $2}')

function install_vim(){
  yum -y install vim net-tools  wget  git bash-completion make bind-utils gcc m4 autoconf unzip zip lrzsz rsync telnet epel-release
}


function install_nginx(){
  yum -y install pcre pcre-devel openssl-devel openssl gcc gcc-c++
  cd /srv/
  wget https://nginx.org/download/nginx-1.16.1.tar.gz
  useradd -s /sbin/nologin -M nginx
  tar -xf nginx-1.16.1.tar.gz
  cd /srv/nginx-1.16.1
  ./configure --prefix=/usr/local/nginx --user=nginx --group=nginx  --with-http_stub_status_module --with-http_ssl_module --with-stream
  make && make install 
  ln -s /usr/local/nginx/sbin/nginx /bin/nginx
  echo "nginx is ok,im $local_ip" > /usr/local/nginx/html/index.html
  sed -i '116a include /usr/local/nginx/conf/conf.d/*.conf;' /usr/local/nginx/conf/nginx.conf
  mkdir /usr/local/nginx/conf/conf.d/
  /usr/local/nginx/sbin/nginx
  echo "/usr/local/nginx/sbin/nginx" >> /etc/rc.d/rc.local
  ps -ef |grep nginx
  echo "nginx 已启动,并设置开机自起到 /etc/rc.d/rc.local"
}

function install_mysql(){
  read -p "请输入新的mysql密码:" new_mysql_pass
  read -p "请再次输入新的mysql密码:" new_mysql_pass2
if [ $new_mysql_pass == $new_mysql_pass2  ];then
  setenforce 0 
  #临时关闭selinux
  sed -i 's/SELINUX=enforcing/SELINUX=disable/' /etc/selinux/config
  systemctl stop mysqld mariadb
  cd /srv/
  wget http://repo.mysql.com/mysql57-community-release-el7-9.noarch.rpm
  rpm -ivh mysql57-community-release-el7-9.noarch.rpm
  #添加检查密钥
  rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
  yum -y  install mysql mysql-server mysql-devel 
  rm -f /etc/my.cnf
  \cp  /root/rice01/mysql/my.cnf  /etc/my.cnf
  useradd  mysql  -M  -s /sbin/nologin
  chown mysql:mysql /etc/my.cnf
  rm -rf /var/lib/mysql/*
  echo ""  > /var/log/mysqld.log
  chown mysql:mysql /var/log/mysqld.log
  mysqld --initialize --user=mysql
  #初始化数据库
  systemctl start mysqld  && systemctl enable mysqld
  systemctl status mysqld
  mysql_pass=$(grep "temporary password"  /var/log/mysqld.log  | awk '{print $NF}')
  mysql -uroot -p"$mysql_pass"  --connect-expired-password -e "set global validate_password_policy=0;"
  mysql -uroot -p"$mysql_pass"  --connect-expired-password -e "set global validate_password_length=1;"
  mysql -uroot -p"$mysql_pass"  --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$new_mysql_pass';"
  systemctl restart mysqld  && systemctl status mysqld
  echo "新的mysql密码是$new_mysql_pass" >> /root/.mysql_history
  echo "已将密码追加到/root/.mysql_history,如忘记可查看"
else
  install_mysql
fi  
}

function install_php8(){
  yum install -y gcc gcc-c++  make zlib zlib-devel pcre pcre-devel  libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers libxslt libxslt-devel oniguruma oniguruma-devel 
  cd /srv
  wget https://www.php.net/distributions/php-8.2.6.tar.gz
  tar -xf php-8.2.6.tar.gz
  cd php-8.2.6/
  ./configure --prefix=/usr/local/php8 --with-config-file-path=/usr/local/php8/etc --with-curl --with-mhash --with-gd --with-gettext --with-iconv-dir --with-kerberos --with-ldap --with-libdir=lib64 --with-libxml-dir --with-openssl --with-pcre-regex --with-pdo-sqlite --with-pear --with-xmlrpc --with-xsl --with-zlib --enable-fpm --enable-ldap --enable-bcmath --enable-libxml --enable-inline-optimization --enable-mbregex --enable-mbstring --enable-opcache --enable-pcntl --enable-shmop --enable-soap --enable-sockets --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-xml --enable-zip --enable-static --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-freetype-dir --with-jpeg-dir --with-png-dir --disable-debug
  make && make install
  echo "PATH=$PATH:/usr/local/php8/bin"  >> /etc/profile
  echo "export PATH"  >> /etc/profile
  source /etc/profile
  cp /usr/local/php8/etc/php-fpm.conf.default  /usr/local/php8/etc/php-fpm.conf
  cp /usr/local/php8/etc/php-fpm.d/www.conf.default  /usr/local/php8/etc/php-fpm.d/www.conf
  cp /srv/php-8.2.6/php.ini-production   /usr/local/php8/etc/php.ini 
  sed -i  '18a pid = run/php-fpm.pid'  /usr/local/php8/etc/php-fpm.conf
  sed -i '942c date.timezone = Asia/Shanghai' /usr/local/php8/etc/php.ini
  sed -i '385c max_execution_time = 300' /usr/local/php8/etc/php.ini
  sed -i '674c post_max_size = 32M'  /usr/local/php8/etc/php.ini
  sed -i '395c max_input_time = 300' /usr/local/php8/etc/php.ini

##编译GD库 cd /srv/php-8.2.6/ext/gd ##   ./configure --with-php-config=/usr/local/php8/bin/php-config --with-jpeg --with-freetype ##  make && make install 

  cp /root/rice01/systemctl/php-fpm.service /usr/lib/systemd/system/php-fpm.service
  systemctl daemon-reload 
  systemctl start php-fpm && systemctl enable php-fpm
}

function install_zabbix(){
  read -p "请输入数据库密码:" mysql_passwd
  read -p "请再次输入数据库密码:" mysql_passwd2
if [ $mysql_pass == $mysql_pass2  ];then
  yum -y install net-snmp-devel curl-devel libevent-devel libxml2 libxml2-devel
  cd /srv/
  wget https://cdn.zabbix.com/zabbix/sources/stable/6.4/zabbix-6.4.9.tar.gz
  tar -xf zabbix-6.4.9.tar.gz
  cd /srv/zabbix-6.4.9
  ./configure --prefix=/usr/local/zabbix --enable-server --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2
  cd /srv/zabbix-6.4.9/
  make && make install
  mysql -uroot -p$mysql_passwd <<EOF 
create database zabbix character set utf8 collate utf8_bin;
grant all on zabbix.* to zabbix@"%" identified by "zabbix";
EOF
  cd /srv/zabbix-6.4.9/database/mysql/
  mysql -uzabbix -pzabbix zabbix < schema.sql
  mysql -uzabbix -pzabbix zabbix < images.sql
  mysql -uzabbix -pzabbix zabbix < data.sql
  mkdir /usr/local/nginx/html/zabbix/
  cp -a /srv/zabbix-6.4.9/ui/* /usr/local/nginx/html/zabbix/
  \cp  /root/rice01/conf/simhei.ttf    /usr/local/nginx/html/zabbix/assets/fonts/DejaVuSans.ttf
  chown -R nginx:nginx /usr/local/nginx/html
  useradd zabbix
  sed -i '118c DBPassword=zabbix' /usr/local/zabbix/etc/zabbix_server.conf
  sed -i '133c DBPort=3306' /usr/local/zabbix/etc/zabbix_server.conf
  # 修改配置文件 AllowUnsupportedDBVersions=1
  cp /root/rice01/systemctl/zabbix-server.service /usr/lib/systemd/system/zabbix-server.service 
  cp /root/rice01/systemctl/zabbix-agent.service /usr/lib/systemd/system/zabbix-agent.service
  systemctl daemon-reload
  systemctl start zabbix-server && systemctl status zabbix-server
  systemctl start zabbix-agent && systemctl status zabbix-agent
  cp /root/rice01/conf/zabbix.conf  /usr/local/nginx/conf/conf.d/
else
  install_zabbix
fi
}

function install_zabbix_agent(){
  yum -y install net-snmp-devel curl-devel libevent-devel
  cd /srv/
  wget https://cdn.zabbix.com/zabbix/sources/stable/6.4/zabbix-6.4.9.tar.gz
  tar -xf zabbix-6.4.9.tar.gz
  cd /srv/zabbix-6.4.9
  ./configure --prefix=/usr/local/zabbix --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2
  make && make install
  useradd zabbix
  cp /root/rice01/systemctl/zabbix-agent.service /usr/lib/systemd/system/zabbix-agent.service
  systemctl daemon-reload
  systemctl start zabbix-agent && systemctl status zabbix-agent
}

function install_redis(){
    cd /srv/
    wget   http://download.redis.io/releases/redis-5.0.6.tar.gz
    tar -xf redis-5.0.6.tar.gz
    cd redis-5.0.6
    make MALLOC=libc
    make install PREFIX=/usr/local/redis
    cp /srv/redis-5.0.6/redis.conf  /usr/local/redis/bin/
    wget http://www.rice666.com:8888/systemctl/redis.service
    cp redis.service /usr/lib/systemd/system/redis.service
    sed -i '136c  daemonize yes'  /usr/local/redis/bin/redis.conf
    ln -s /usr/local/redis/bin/redis-cli /usr/bin/redis-cli
    systemctl daemon-reload
    systemctl start redis.service && systemctl status redis
}

function install_rabbitmq(){
    yum -y install gcc glibc-devel make ncurses-devel openssl-devel xmlto perl wget gtk2-devel binutils-devel
    cd /srv
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
    cd /srv
    wget https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
    chmod +x speedtest.py
    mv speedtest.py /usr/local/bin/speedtest
    echo "直接执行speedtest即可测试网速"
}

function install_jenkins(){
    cd /srv/
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    yum -y install jenkins  
    wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm
    rpm -ivh jdk-17_linux-x64_bin.rpm
    
    systemctl start jenkins && systemctl enable jenkins &&systemctl status jenkins
    wget https://raw.githubusercontent.com/happy789450/rice01/main/conf/jenkins.conf
    echo "推荐使用java17以上版本，不然可能起不来。默认端口号8080,可以通过nginx代理访问"
}

function install_shadowsocks(){
    read -p "请输入密码:" shadow_pass
    read -p "请选择端口号:" shadow_port
    yum -y install python3
    pip3 install https://github.com/shadowsocks/shadowsocks/archive/master.zip -U
    #pip3 install shadowsocks
    cd /srv/
    wget https://raw.githubusercontent.com/happy789450/rice01/main/systemctl/shadowsocks.service 
    wget https://raw.githubusercontent.com/happy789450/rice01/main/conf/shadowsocks.json
    mkdir /etc/shadowsocks
    cp shadowsocks.json  /etc/shadowsocks/shadowsocks.json
    cp shadowsocks.service  /usr/lib/systemd/system/ 
    sed -i "5c  \ \ \"$shadow_port\":\"$shadow_pass\"" /etc/shadowsocks/shadowsocks.json
    systemctl daemon-reload 
    systemctl start shadowsocks && systemctl enable shadowsocks &&systemctl status  shadowsocks 
    
}

function install_node(){
    cd /srv/
    wget https://nodejs.org/dist/v14.17.6/node-v14.17.6-linux-x64.tar.xz
    tar -xf node-v14.17.6-linux-x64.tar.xz
    mv  node-v14.17.6-linux-x64   /usr/local/nodejs
    ln -s /usr/local/nodejs/bin/node /usr/bin/node
    ln -s /usr/local/nodejs/bin/npm /usr/bin/npm
    ln -s /usr/local/nodejs/bin/npx /usr/bin/npx
    node -v && npm -v && npx -v 
}


function install_gitlab(){
    curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
    yum -y install gitlab-ee
    echo "安装完毕，需要修改配置文件/etc/gitlab/gitlab.rb
          然后执行  gitlab-ctl reconfigure  才能访问"

}

function install_openresty_openstar(){
    cd /srv/
    wget https://openresty.org/download/openresty-1.19.9.1.tar.gz
    tar -xf openresty-1.19.9.1.tar.gz
    cd openresty-1.19.9.1
    ./configure --prefix=/opt/openresty --with-luajit
    make && make install
    chown nobody:nobody -R /opt/openresty
    cd /opt/openresty
    wget -O openstar.zip https://codeload.github.com/starjun/openstar/zip/master
    unzip -o openstar.zip
    mv -f openstar-master openstar
    chown nobody:nobody -R openstar
    echo "已经安装openresty 和 openstar 但是并未启动"
    

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
  install_php8
elif [ "$choice" = 5 ];then
  install_zabbix
elif [ "$choice" = 6 ];then
  install_vim
  install_nginx
  install_mysql
  install_php8
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
elif [ "$choice" = 13 ];then
  install_node
elif [ "$choice" = 14 ];then
  install_gitlab
elif [ "$choice" = 15 ];then
  install_openresty_openstar
elif [ "$choice" = 0 ];then
  readme
else
  echo "请重新输入" 
fi

