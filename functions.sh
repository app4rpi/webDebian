#!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./function.sh
source ./context.sh
#  ---------------------------------------------------------
function isCorrect(){
while true; do  echo -en "\t"
    read -r -p "Are all correct & continue? [Y/n] " input
    case $input in 
        [cC][yY][eE][sS]|[sS][iI]|[yYsS]) return 1 ;;
        [xX][nN][oO]|[nN]) return 0 ;; 
        *) echo -en  "\tInvalid input...  ->   " ;;
        esac
    done
return 1
}
# --------------------------------------------------------------------------
function isOk(){
echo -en "  ::  It's OK?  >  "; 
while IFS= read -rsn1 key; do
    [[ $key =~ ^[YySs]$ ]] && return 1
    [[ $key =~ ^[Nn]$ ]] && return 0
    done
return 1
}
# --------------------------------------------------------------------------
function downloadGit(){
echo -e '\n'$LINE'\nDownload git files:'
echo -e "\tCopy & overwriting all bash script files except <context.sh>"
echo -e "\tTo modify <context.sh> erase file first\n"$LINE
isOk; val=$?;
[[ $val == 0 ]] && return
file=(start.sh setupServer.sh startup.sh nginxConfig.sh setupDav.sh letsencrypt.sh nginxStart.sh sslConfig.sh configDav.sh test.sh)
echo-n "Bash files: "
for ((i=0; i<${#file[@]}; i++)); do
    echo -n '<'${file[i]}'> : '
    wget -q https://raw.githubusercontent.com/app2linux/webDebian/master/${file[i]} -P ./
    chmod +x ./${file[i]}
    done
[[ ! -f ./context.sh ]] && wget -q https://raw.githubusercontent.com/app2linux/webDebian/master/context.sh -P ./
echo -e "\n"$LINE$LINE"\n\n\tExit now & restart bash script file \n"
echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
echo
exit
}
#  ----------------------------------
function restartContext(){
echo -e '\n'$LINE'\nDelete <context.sh> config files,'
echo -e "Restore from file or download new file from GitUb\n"$LINE
isCorrect; val=$?;
[[ $val == 0 ]] && return
mv ./context.sh ./context.old
[[ -f context.bak ]] && cp ./context.bak ./context.sh || { wget https://raw.githubusercontent.com/app2linux/webDebian/master/context.sh -P ./; chmod +x ./context.sh; }
echo -e "\tFile <context.sh> restored."
echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
return 1
}
#  ----------------------------------
function viewMain(){
echo -e "\n"$LINE$LINE"\n\nEnvironamental variables.\n"$LINE$LINE
echo -e "Main domain:[$mainDomain]   IP:[$mainIP]\n"$LINE
echo -en "Folders:  App:[$appFolder]  Backup:[$backupFolder]  www:[$wwwFolder]  Error dir:[$errorDir]  "
echo -en "Error style: "
[[ ${errorStyleLocal} = true ]] && echo 'Local' || echo 'Global'
}
#  ----------------------------------
function viewDomains(){
echo -e $LINE$LINE"\n[domain IP workDir nameSite colorSite subDirIn]\n"$LINE
title=(${context[0]:1:-1})
for ((i=1; i<${#context[@]}; i++));  do
    data=(${context[i]:1:-1})
    [[ -z $data ]] && break
    for ((j=0; j<${#data[@]}; j++)); do
        echo -n "["${data[j]}']  '
        done
    echo
    done
echo $LINE$LINE
}
#  ----------------------------------
function viewContext(){
source ./context.sh
viewMain
echo -e "SSL/TLS: [$SSL]   email:[$SSLemail]   Domains:[$SSLdomains]"
temp=($DAVconfig)
echo -e "WebDav:  Server:[${temp[0]}]   email:[${temp[2]}]   Pw:[${temp[3]}]"
viewDomains
echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
return 1
}
# --------------------------------------------------------------------------
function askDomain(){
echo -e "\n\n"$LINE$LINE"\nWeb config options in line orders:\n(all in the same line):\n"$LINE
echo -e "    <nameMainDomain>.<extension> <subdomain> ...  [NOIP] [ERRORLOCAL]\n"
echo -e "    [x]  Cancel & Return\n"$LINE$LINE 
}
# --------------------------------------------------------------------------
function addSite(){
data=(${@});
[[ -z $data ]] && return
thisSite="server {\nlisten 80"
[[ ${data[0]} = ${mainDomain} ]] && thisSite+=" default_server"
thisSite+=";\nlisten [::]:80;\nserver_name "
[[ -n ${data[0]:1:-1} ]] && thisSite+=${data[0]} || thisSite+="_"
thisSite+=";\ncharset utf-8;\nroot ${wwwFolder}/${data[2]};\nindex index.html index.htm;\n"
thisSite+="# location\nlocation /include { alias "${wwwFolder}/include"; autoindex off; }\n"
thisSite+="include /etc/nginx/errors.conf;\ninclude /etc/nginx/drop.conf;\n}"
echo -e $thisSite > ${appFolder}/${data[3]}.conf
if [ ! -z ${data[5]:1:-1} ]; then 
    line2add="location /"${data[0]%%.*}" { alias "${wwwFolder}/${data[2]}"; autoindex off; }"
    sed -i "/# location/i ${line2add}" ${appFolder}/${data[5]}.conf
    fi
return
}
# --------------------------------------------------------------------------
function addW3(){
data=(${@});
[[ -z $data ]] && return
[[ ! -d ${wwwFolder}/${data[2]} ]] && mkdir -p ${wwwFolder}/${data[2]} ${wwwFolder}/${data[2]}/css ${wwwFolder}/${data[2]}/scripts ${wwwFolder}/${data[2]}/img
thisSite='<!DOCTYPE html>\n<html lang="es-ES"><head><meta charset="utf-8" />\n<style>body{background:'
[[ -n ${data[4]:1:-1} ]] && thisSite+=${data[4]:1:-1} || thisSite+=${mainColor}
thisSite+=';font:bold normal 4em "Arial"}\nh1{color:#ded;margin-top:21%;text-align:center;}</style>\n'
thisSite+="</head><body><h1>"
[[ -n ${data[0]:1:-1} ]] && thisSite+=${data[0]} || thisSite+='Welcome to nginx'
thisSite+="</h1></body></html>"
echo -e $thisSite > ${wwwFolder}/${data[2]}/index.html
return
}
# --------------------------------------------------------------------------
function addDomain(){
domain=$1
random=$(date +%1N);
[[ ${domain} == *${mainDomain} ]] && { subDomain=${domain%$mainDomain}; subSite=' mainSite'; } || { subDomain=${domain}; subSite=''; }
subDomain=${subDomain//.}
temp='"('${domain}" '' "${subDomain}" "${subDomain}Site" '"${color[$random]}"'"${subSite}')"'
echo -n ${temp}
isOk; ok=$?;
if [ $ok ]; then
    sed -i "/^)/i${temp}" context.sh
    addSite ${temp:2:-2}
    addW3 ${temp:2:-2}
    echo "Added domain & nginx config"
else
    echo "Discarded add domain"
fi
return
}
# --------------------------------------------------------------------------
function delDomain(){
temp=$(sed -e "/^\"(${domain} / !d" context.sh)
temp=( ${temp:2:-2} )
isOk; ok=$?;
if [ $ok ]; then
    sed -i "s/\"(${domain} .*$//;/^$/d" context.sh
    rm -f $appFolder/${temp[3]}.conf
    [[ ! ${temp[5]} ]] && rm -rf $wwwFolder/${temp[2]}
    echo "Deleted domain & nginx config"
else
    echo "Discard delete domain"
fi
return
}
# --------------------------------------------------------------------------
function manageDomain(){
source ./context.sh
option=$1
echo
echo -n ' > '
[[ $verifiedContext = false ]] && option='all' || { echo -e "\n\n"$LINE$LINE"\n\nDomains:"; viewDomains; }
case $option in
    all) echo -e "\nConfig Main domain:\n"$LINE"\n    [NOIP] [ERRORLOCAL] <nameMainDomain>.<extension> <subdomain> <subdomain> <...>\n" ;;
    add) echo -e "\nAdd domains:\n"$LINE"\n    [<subdomain>]<nameMainDomain>.<extension> ...\n" ;;
    del) echo -e "\nDelete domains:\n"$LINE"\n    [<subdomain>]<nameMainDomain>.<extension> ...\n" ;;
    esac
echo -e "    [x]  Cancel & Return\n"$LINE$LINE 
read -p "   > " lineOrder
if [[ $lineOrder =~ ^(x|X) || ! $lineOrder ]]; then 
    echo; return;
fi
if [ $option = all ]; then
    echo -e "\n"$LINE$LINE"\n\nInitial configuration file"
    ./startup.sh $lineOrder
    echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
    return
fi
lineOrder=($lineOrder)
echo -en $LINE$LINE"\n"
[[ $option = add ]] && echo -n "Add" || echo -n "Delete"
echo -n " domains >  "
for domain in ${lineOrder[*]}; do
    echo -n "[ "$domain" ] "
    done
echo -e "\n"
isCorrect
valor=$?; [[ "${valor}" == 0 ]] && { echo; return; }
echo -e "\n"$LINE$LINE"\nDomains:\n"$LINE
for domain in ${lineOrder[*]}; do
    echo -n "[ "$domain" ] "
    [[ ! ${domain} = *"."* ]] && { echo "> It's not a domain!"; continue; }
    [[ ${domain} = $mainDomain ]] && { echo "> It's main domain!"; continue; }
    if [ $option = add ]; then
        [[ ${context[@]} = *"(${domain} "* ]] && { echo "> Domain already exist!"; continue; }
        addDomain ${domain}  
    else
        [[ ${context[@]} != *"(${domain} "* ]] && { echo "> Non-existent domain"; continue; }
        delDomain ${domain}  
    fi
    done
echo $LINE$LINE
echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
echo
return
}
# --------------------------------------------------------------------------
function deleteDomain(){
echo -e "\n\n"$LINE$LINE"\n\nDomains:"
viewDomains
echo -e "\nDelete domains:\n"$LINE
echo -e "    [<subdomain>]<nameMainDomain>.<extension> ...\n"
echo -e "    [x]  Cancel & Return\n"$LINE$LINE 
read -p "   > " lineOrder
if [[ $lineOrder =~ ^(x|X) || ! $lineOrder ]]; then 
    echo; return;
fi
lineOrder=($lineOrder) 
echo -en $LINE$LINE"\nDelete domains >  "
for domain in ${lineOrder[*]}; do
    echo -n "[ "$domain" ] "
    done
echo -e "\n"
isCorrect
valor=$?; [[ "${valor}" == 0 ]] && { echo; return; }
echo -e "\n"$LINE$LINE"\nDomains:\n"$LINE
for domain in ${lineOrder[*]}; do
    echo -n "[ "$domain" ] "
    [[ ! ${domain} = *"."* ]] && { echo "> It's not a domain!"; continue; }
    [[ ${domain} = $mainDomain ]] && { echo "> Unable to delete: It's main domain!"; continue; }
    [[ ${context[@]} != *"(${domain} "* ]] && { echo "> Non-existent domain"; continue; }
    echo "Deleted domain & nginx config"
    done
echo -e $LINE
echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
return
}
# --------------------------------------------------------------------------
function verifyConfig(){
source ./context.sh
echo -e '\n\n\n'$LINE"\n\tVerify configuration >  "
echo -e $LINE
echo -e "Verify <context.sh> files: \n"$LINE
[[ $verifiedContext = false ]] && { manageDomain all; return; }
for ((i=1; i<${#context[@]}; i++));  do
    site=(${context[i]:1:-1})
    [[ -z $site ]] && break
    echo -en '[ '${site[3]}' ]  '
    if [ -f $appFolder/${site[3]}.conf ]; then
        echo -n "<config file> is OK  -  "
    else
        echo -n 'Unavailable config: Create it '
        isOk; ok=$?;
        if [ $ok ]; then
            addSite ${context[i]:1:-1}
            echo -n " > Added nginx config"
        else
            echo -n " > Discarded config"
        fi
    fi
    if [ -d $wwwFolder/${site[2]} ]; then
        echo "<web dir> is OK "
    else
        echo -n 'Unavailable web dir. Create it?  '
        isOk; ok=$?;
        if [ $ok ]; then
            addW3 ${context[i]:1:-1}
            echo -n " > Added web dir & files"
        else
            echo -n " > Discarded"
        fi
    fi
    done
echo -e '\n'$LINE"\n\nVerify nginx config dir: $appFolder\n"$LINE
arr=( "${appFolder}"/*.conf )
for f in "${arr[@]}"; do
site=${f#"$appFolder"}
echo -en "[ ${site:1} ]    >  "
if [[ ${context[@]} == *" ${site:1:-5} "* ]]; then
echo "Ok! : config site at <context.sh>"
elif  [[ ${site} == "/default.conf" ]]; then
echo "Protected config site"
else
echo -en "Delete unknown config site"
        isOk; ok=$?;
        if [ $ok = 1 ]; then
rm -f ${f}
            echo " > Deleted files"
        else
            echo " > Discarded"
        fi
fi
done
echo -e $LINE"\n\nVerify web folder: $wwwFolder\n"$LINE
arr=( "${wwwFolder}"/**/ )
for f in "${arr[@]}"; do
site=${f#"$wwwFolder"}
echo -en "[ ${site:1:-1} ]    >  "
if [[ ${context[@]} == *" ${site:1:-1} "* ]]; then
echo "Ok! : web folder at <context.sh>"
elif  [[ ${protectetLocations} == *"${f:0:-1}"* ]]; then
echo "Protected web folder"
else
echo -en "Delete orphan www folder"
        isOk; ok=$?;
        if [ $ok = 1 ]; then
rm -rf ${f} 
            echo " > Deleted files & folder"
        else
            echo " > Discarded"
        fi
fi
done

echo -e $LINE
echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
return
}
# --------------------------------------------------------------------------


#  ----------------------------------
function downloadNginx() {
echo -e '\n\n'$LINE"\nDownload Nginx Docker Image: [ "${dockerNginxImage}' ]'
echo -e $LINE
if [[ -z $(docker images -q $dockerNginxImage) ]]; then
    echo -e "\tLocal Docker image does not exist.\n\tDownload image from DockerHub...\n"
    docker pull $dockerNginxImage
    [[ -z $(docker images -q $dockerNginxImage) ]] && { echo -e "\n\tUnavailable docker image. Trial start docker finished.\n\tUse console options to start docker nginx image"; return 0;}
    echo -e "\n[ "$dockerImage" ]  already downloaded ... "
else 
    echo -e "\n\tLocal Docker image already downloaded.\n\tDelete image first: \n\n\t>#  docker rmi $dockerNginxImage\n"
fi
echo -e $LINE
echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
return
}
#  ----------------------------------
function statusDocker() {
return
echo -e '\n\n'$LINE$LINE"\n\t Docker Container Status"
echo -e $LINE
docker info
echo -e $LINE
systemctl status docker
echo -e $LINE$LINE
echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
}
#  ----------------------------------
function statusContainer() {
temp=$1
echo -e '\n\n'$LINE$LINE"\n\t Docker Container Status"
echo -e $LINE
docker inspect ${temp}
echo -e $LINE
docker logs ${temp}
echo -e $LINE$LINE
echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
return
}

#  ----------------------------------
function restartContainer() {
echo -e '\n\n'$LINE$LINE"\n\tRestart Docker Container: [ "${dockerNginxContainer}' ]'
echo -e $LINE
if [[ -n "$(docker ps -q -f status=running -f name=^/${dockerNginxContainer}$)" ]]; then
    echo -e "\t[ ${dockerNginxContainer} ] container exists.\n\tStop & delete container"
    docker stop ${dockerNginxContainer} && docker rm ${dockerNginxContainer}
fi
echo -e "\nStarting  container:[ ${dockerNginxContainer} ] Image:[${dockerNginxImage}] config:[${appFolder}] www:[${wwwFolder}]"
docker run -d --restart always --net=host -v ${wwwFolder}:/var/www/ -v ${appFolder}:/etc/nginx/conf.d/ --name ${dockerNginxContainer} ${dockerNginxImage}
echo -e $LINE$LINE
echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
return
}
# --------------------------------------------------------------------------
