#!/bin/bash
#for 循环的2种写法 计算1+2+...+100
function one(){
local result=0
for i in {1..100}
  do
    let result=$result+$i
  done 
echo "The sum of 1+2+...+100 is : $result"
}
one

function two(){
local result=0
for (( y=1;y<=100;y=y+1 ))
  do
    result=$(( $result+$y ))
  done

echo $result
}
two
