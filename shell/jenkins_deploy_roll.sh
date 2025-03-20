#!/bin/bash
ver=$1
back_version=$3
time=$(date +%F-%H:%M:%S)
back_path=/var/lib/jenkins/workspace/test/back/$1
roll_path=/var/lib/jenkins/workspace/test/back/$back_version
index_path=/root/test/html
#index_path=/usr/local/nginx/html

echo $back_version

function update (){
if [ -d $back_path ];then
  echo "目录存在 >>deploy.log" 
else
sudo  mkdir $back_path
fi

#备份当前版本
sudo tar -zcvf ./back/$ver/index.tar.gz  -Cweb/ index.html
#sudo tar -zcvf ./back/$ver/index.tar.gz -C$index_path index.html
sudo \cp web/index.html $index_path

if [ $? -eq 0 ] ;then
  echo "$time $ver 执行成功" >>deploy.log
fi
}

function rollback (){
sudo tar -xf $roll_path/index.tar.gz -C $index_path
echo "$time 已回滚为版本 $back_version" >> roll.log
}


if [ "$2" == "deploy" ]; then
  update
elif [ "$2" == "rollback" ]; then
  rollback
else
  echo "参数错误"
fi
