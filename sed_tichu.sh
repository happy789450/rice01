list=`cat 13.txt`
for i in $list
do
  sed -i  "/$i.crt/,/$i.key/!s/www.$i//g" https.conf
  sed -i  "/$i.crt/,/$i.key/!s/m.$i//g" https.conf
  sed -i  "/$i.crt/,/$i.key/!s/$i//g" https.conf
done
