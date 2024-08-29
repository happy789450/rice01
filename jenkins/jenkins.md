# jenkins 修改端口号



```
vim /usr/lib/systemd/system/jenkins.service
Environment="JENKINS_PORT=8080"
# 将8080修改为其他端口号即可 如 8050 
# systemctl start jenkins
```


