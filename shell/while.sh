#!/bin/bash
#输入的数值进行比较判断
PRICE=$(expr $RANDOM % 1000)
TIMES=0

echo "商品的价格为0-999之间，猜猜看是多少？"
while true
do
  read -p "请输入您猜的价格：" INT
let TIMES++

	if [ $INT -eq $PRICE ] ; then
	  echo "恭喜您猜对了，实际价格是 $PRICE"
	  echo "您总共猜了 $TIMES 次"
	exit 0
	elif [ $INT -gt $PRICE ] ; then
	  echo "太高了"
	else
	  echo "太低了"
	fi
done
