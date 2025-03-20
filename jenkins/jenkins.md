# jenkins 修改端口号



```
vim /usr/lib/systemd/system/jenkins.service
Environment="JENKINS_PORT=8080"
# 将8080修改为其他端口号即可 如 8050 
# systemctl start jenkins
```

# jenkins 添加构建历史描述
# 更改jenkins安全配置
# Manage Jenkins -> Configure Global Security，将Markup Formatter的设置更改为Safe HTML。
# 安装插件
Build Name and Description Setter

在构建环境里选择设置 Set Build Name
eg:
第#${BUILD_NUMBER} 次$param 操作，版本号是 $BUILD_NUMBER  $back_version


## 执行shell 参考
```
#!/bin/bash
cd web
sudo git pull
cd ..
echo "$ver $choise $ver"
bash -x jenkins_deploy_roll.sh $ver $choise $ver 
```
