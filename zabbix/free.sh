#!/bin/bash
m_total=$(free |grep "Mem"| awk '{print $2}')
m_used=$(free |grep "Mem"| awk '{print $3}')
m_free=$(free |grep "Mem"| awk '{print $4}')
m_available=$(free |grep "Mem"| awk '{print $NF}')

#echo "mtotal is $m_total
#mused is $m_used
#mfree is $m_free
#mava is $m_available"

now_mused=$(awk -v m_to=$m_total -v m_free=$m_free -v m_ava=$m_available 'BEGIN {printf "%.2f%%\n", ((1-(m_free+m_ava) / m_to)) * 100}')

#echo "内存使用率是 $now_mused"
echo "$now_mused" |tr -d "%"
