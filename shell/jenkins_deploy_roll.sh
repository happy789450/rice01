#!/bin/bash
back_path=/var/lib/jenkins/workspace/test/back/$1
roll_path=/var/lib/jenkins/workspace/test/back/$back_version
index_path=/usr/local/nginx/html
ver=$1
back_version=$3

function update (){
if [ -d $back_path ];then
  echo "目录存在 >>deploy.log" 
else
  mkdir $back_path
fi

tar -zcvf ./back/$ver/index.tar.gz -C$index_path index.html
\cp index.html $index_path

if [ $? -eq 0 ] ;then
  echo "$ver 执行成功" >>deploy.log
fi
}

function rollback (){
tar -xf $roll_path/index.tar.gz -C $index_path
echo "已回滚为版本 $back_version" >> roll.log
}


if [ "$2" == "deploy" ]; then
  update
elif [ "$2" == "rollback" ]; then
  rollback
else
  echo "参数错误"
fi
