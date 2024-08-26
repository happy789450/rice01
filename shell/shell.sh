#!/bin/bash
echo "shell脚本本身的名字: $0"
echo "传给shell的第一个参数: $1"
echo "传给shell的第二个参数: $2"
echo "传给shell的所有参数,'\$*'把所有的参数看成一个整体: $*"
echo "传给shell的所有参数,'\$@'把每个参数区分对待: $@"
echo "传给shell的所有参数个数: $#"


echo "执行脚本 bash a.sh 1 2 3 输出结果为 123 循环一次"
for i in "$*"
  do 
    echo $i
  done

echo "执行脚本 bash a.sh 1 2 3 输出结果为 循环三次"
for j in "$@"
  do 
    echo $j
  done
