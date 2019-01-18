#!/bin/bash
# This script has been tested on Debian 8 Jessie image
#
# chmod +x ./context.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
echo -e "Environamental variables."
ifconfig eth0 | grep inet | awk '{ print $2 }'
#
export RELEASE=$(lsb_release -cs)
#
export mainDomain=""
export mainIP=""
export mainColor="#BA0020"
#
export auxDomain=''
export auxIP='' 
#
export appFolder="/app/nginx"
export wwwFolder="/var/www"
export errorDir=/var/www/error
export errorStyle=True 		
#errorStyle=True for Global, [/var/www/error]  | =False for Local, [www<site>/style dir]
color=(#DC443A #98243A #11589F #715138 #D69C2F #616247 #898E8 #2e5090C #5F4B8B #BA0020 #0E3A53)
#
echo "# Data context web : [Config folder: " ${appFolder} "]  [Web folder: "${wwwFolder}"]"
echo "# --------------------------------------------------------------------------"
echo "# Data order [ domain : IP : workDir nameSite colorSite subDirIn ]"
echo "# --------------------------------------------------------------------------"
export context=("(domain IP workDir nameSite colorSite subDirIn)"
"("${mainDomain}" "${mainIP}" html mainSite "${mainColor}")"
"()"
"()"
"()"
"()"
"()"
"()"
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
export verifiedContext=false
echo "# --------------------------------------------------------------------------"

