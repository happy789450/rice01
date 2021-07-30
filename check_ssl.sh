#/bin/bash
## 本脚本通过检测域名.crt文件判断域名是否过期，与检测域名相比速度快很多
key_path=/opt/fab/conf/key/
conf_path=/opt/fab/conf/wc_nginx/openstar_conf/
now_time=$(date +%s)

#cat $conf_path/*https.conf  |grep crt |grep -v "ahf.cmx073fmdmbcav.com.crt"| awk  -F / '{print $NF}'|tr -d ";"|sort |uniq  >crt.txt

> ssl_time.txt
> lt20.txt
>no_crt.txt

for i in $(diff   pass.txt crt.txt  | grep crt |awk '{print $2}')
  do
    crt=$(find $key_path -type f -name "$i" |xargs  ls -1 -t | head -1)
        if [ ! -z "$crt" ] ;then
             #echo $crt
                crt_time=$(date -d "$(openssl x509 -in  $crt   -noout -dates  | awk -F = 'NR==2{print $2}')" +%s)
                echo "正在检测域名组 $i"
                let day_time=$(($crt_time - $now_time))/86400  ##计算证书时间
                    if [ $day_time -lt 21 ] ;then
                                echo "$crt 剩余时间是 $day_time" >> ssl_time.txt
                                echo $i |sed -n 's/.crt//p' >> lt20.txt
                    fi
        else
                echo $i 不存在 >> no_crt.txt;
        fi
  done
msg=$(cat /tmp/ssl_time.txt)
#curl -s -X POST https://api.telegram.org/bot1096628457:AAFOa7PO_RwPMWWvnYfeSYPtI3DaReu_IUE/sendMessage? -d chat_id=-380732097 -d parse_mode=${HTML} -d text="$msg"
