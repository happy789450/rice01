#!/bin/bash
for i in `find log2/ -type f -mtime -30`
do
        if [ "${i##*.}"x = "gz"x  ];then
zcat $i | awk '{print $3,$6,$2}'  |cut -d "-" -f2 |sed 's/"//'|sed 's/\[//'|cut -d ":" -f1 |sort|uniq -c |sort -n| awk 'OFS="," {print $4 ,$3,$2,$1}'  >> api.txt
        else
cat $i |awk '{print $3,$6,$2}'  |cut -d "-" -f2 |sed 's/"//'|sed 's/\[//'|cut -d ":" -f1 |sort|uniq -c |sort -n| awk 'OFS="," {print $4 ,$3,$2,$1}' >> api.txt
        fi
done
