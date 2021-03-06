!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./sslConfig.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="-----------------------------------------------"
#  ---------------------------------------------------------
source ./context.sh
#  ---------------------------------------------------------
#
[[ ! -d ${appFolder}/letsencrypt ]] && mkdir -p ${appFolder}/letsencrypt
sslDir="/etc/letsencrypt/live/"$mainDomain
echo $sslDir
files=(cert.pem fullchain.pem privkey.pem)
for file in ${files[*]} ; do
    [[ ! -f ${appFolder}/letsencrypt/$file && -f ${sslDir}/$file ]] && cp -R -L ${sslDir}/$file ${appFolder}/letsencrypt/$file
    done
ls ${appFolder}/letsencrypt
echo $LINE
ssl_mydomain="ssl_certificate     /etc/nginx/conf.d/letsencrypt/fullchain.pem;\n"
ssl_mydomain+="ssl_certificate_key /etc/nginx/conf.d/letsencrypt/privkey.pem;\n"
ssl_mydomain+="ssl_stapling on;\nssl_stapling_verify on;\nssl_session_timeout 5m;\n"
echo $LINE
[[ ! -f ${appFolder}/ssl_mydomain.tld ]] && echo -e $ssl_mydomain >> ${appFolder}/ssl_mydomain.tld
echo '> '${appFolder}/ssl_mydomain.tld
cat ${appFolder}/ssl_mydomain.tld
echo $LINE
for ((i=1; i<${#context[@]}; i++)); do
    data=(${context[i]:1:-1})
    [[ -z $data ]] && break
    file=${appFolder}/${data[3]}.conf
    echo '> '${file}
    if [[ ! -f ${appFolder}/${data[3]}.old ]]; then
        cp ${file} ${appFolder}/${data[3]}.old
        sed -ie "s/80.*$/443 ssl;/g" ${file}
        sed -i '/server_name/a include /etc/nginx/conf.d/ssl_mydomain.tld;' $file
        cat $file 
        echo $LINE
        else
        echo -e '<'${appFolder}/${data[3]}'.old> already exist.\nDelete <.sh> file & rename file <.old> to <.sh> first!'
        fi
    done
echo $LINE
myText="server {\n\tlisten 80 default_server;\n\tlisten [::]:80 default_server;\n\t"
myText+="server_name _;\n\treturn 301 https://\$host\$request_uri;\n\t}\n"
if [[ ${mainDomain:1:-1} ]]; then
    myText+="server {\n\tlisten 45.62.246.63:443 ssl;\n\tlisten [::]:443 ssl;\n\t"
    myText+="server_name www."$mainDomain";\n\tinclude /etc/nginx/conf.d/ssl_mydomain.tld;\n\t"
    myText+="return 301 https://"$mainDomain"\$request_uri;\n\t}\n"
    fi
echo '> '${appFolder}/default.conf
echo -e $myText
echo -e $myText > ${appFolder}/default.conf
echo $LINE$LINE
echo 'Restart now the web server ...'
exit
