#!/usr/bin/expect

# 设置超时时间
set timeout 30

# 获取命令行参数
#set username [lindex $argv 0]
#set password [lindex $argv 1]
#set database [lindex $argv 2]
set username root
set password $tmp_pass
set database "mysql"

# 启动 MySQL 客户端
spawn mysql -u $username -p -D $database

# 等待密码提示
expect "Enter password:"

# 发送密码
send "$password\r"

# 等待 MySQL 提示符
expect "mysql>"

# 发送 SQL 查询
send "ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass123!';\r"

send "show databases;\r"
send "SET GLOBAL validate_password.policy = 'LOW';\r"
send "SET GLOBAL validate_password.length = 6;\r"
send "ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';\r"
# 等待查询结果
expect "mysql>"

# 退出 MySQL
send "exit\r"

# 结束 expect
expect eof
