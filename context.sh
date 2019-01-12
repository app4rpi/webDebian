#!/bin/bash
# This script has been tested on Debian 8 Jessie image
#
# chmod +x ./context.sh
#
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
echo -e "Environamental variables."
ifconfig eth0 | grep inet | awk '{ print $2 }'
#
export RELEASE=$(lsb_release -cs)
#
export mainDomain="mydomain.com"
export mainIP="10.0.0.21"
export mainColor='#898E8C'
#
export auxDomain=''
export auxIP='' 
#
export errorDir=/var/www/error
export appFolder="/app/nginx"
export wwwFolder="/var/www"
#
echo "# Data context web : [Config folder: " ${appFolder} "]  [Web folder: "${wwwFolder}"]"
echo "# --------------------------------------------------------------------------"
echo "# Data order [ domain : IP : workDir nameSite colorSite subDirIn ]"
echo "# --------------------------------------------------------------------------"
export context=("(domain IP workDir nameSite colorSite subDirIn)"
"("${mainDomain}" "${mainIP}" html mainSite #2e5090)"
"(blog."${mainDomain}" "${mainIP}" blog blogSite #5F4B8B mainSite)"
"(cloud."${mainDomain}" "${mainIP}" cloud cloudSite #BA0020 mainSite)"
"(iot."${mainDomain}" "${mainIP}" iot iotSite #0E3A53 mainSite)"
"()"
"()"
) 
#
title=(${context[0]:1:-1})
for ((i=1; i<${#context[@]}; i++))
do
    data=(${context[i]:1:-1})
    [[ -z $data ]] && break
    for ((j=0; j<${#data[@]}; j++))
    do
    echo -n "["${title[j]}":" ${data[j]}']  '
    done
echo
done
echo "# --------------------------------------------------------------------------"
