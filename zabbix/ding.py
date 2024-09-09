#!/usr/bin/python
#-*- coding: utf-8 -*-
#zabbix钉钉报警
# 使用pytho2 参数1是钉钉号 参数2是站位 参数3是告警内容
import requests,json,sys,os,datetime

#webhook="https://oapi.dingtalk.com/robot/send?access_token=feb43aea482d9da72e781d92dbfc074f701642a166f31194ff347954f500a404"
webhook="https://oapi.dingtalk.com/robot/send?access_token=97d2cfc96d4c07a87a726a9cab4cb1b2c0f972460507cfd8bdc27afd1bc118a9"
 
#说明：这里改为自己创建的机器人的webhook的值
user=sys.argv[1]
#发给钉钉群中哪个用户
text=sys.argv[3]
#发送的报警内容
data={
    "msgtype": "text",
    "text": {
        "content": text
    },
    "at": {
        "atMobiles": [
            user
        ],
        "isAtAll": False
    }
}
#钉钉API固定数据格式
headers = {'Content-Type': 'application/json'}
x=requests.post(url=webhook,data=json.dumps(data),headers=headers)
if os.path.exists("/var/log/zabbix/dingding.log"):
    f=open("/var/log/zabbix/dingding.log","a+")
else:
    f=open("/var/log/zabbix/dingding.log","w+")
f.write("\n"+"--"*30)
if x.json()["errcode"] == 0:
    f.write("\n"+str(datetime.datetime.now())+"    "+str(user)+"    "+"发送成功"+"\n"+str(text))
    f.close()
else:
    f.write("\n"+str(datetime.datetime.now()) + "    " + str(user) + "    " + "发送失败" + "\n" + str(text))
    f.close()
#将发送的告警信息写入本地日志/var/log/zabbix/dingding.log中
