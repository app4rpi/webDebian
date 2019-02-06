#!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./setup.sh
# wget https://raw.githubusercontent.com/app2linux/webDebian/master/setup.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
#  ---------------------------------------------------------
LINE="---------------------------------------"
lineOrder="${@,,} "
#  ---------------------------------------------------------
function isContinue(){
echo -n "[x] Cancel & break     [c] Continue   > "
while true; do  read -rsn1  input
  case $input in 
	[cC]) break ;;
	[xX]) { echo;exit 0;} ;; 
 esac
done
return 1
}
#  ---------------------------------------------------------
clear 
echo -e "#\nAutomatic install & config & start server and web server."
#!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./setup.sh
# wget https://raw.githubusercontent.com/app2linux/webDebian/master/setup.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="---------------------------------------"
#  ---------------------------------------------------------
function isContinue(){
echo -n "[x] Cancel & break     [c] Continue   > "
while true; do  read -rsn1  input
  case $input in 
	[cC]) break ;;
	[xX]) { echo; exit 0;} ;; 
 esac
done
return 1
}
#  ---------------------------------------------------------
function viewContext(){
source ./context.sh
echo -e "\nEnvironamental variables.\n"$LINE$LINE
echo "Main domain:[$mainDomain]   IP:[$mainIP]"
echo -e $LINE$LINE"\n[domain IP workDir nameSite colorSite subDirIn]\n"
title=(${context[0]:1:-1})
for ((i=1; i<${#context[@]}; i++));  do
    data=(${context[i]:1:-1})
    [[ -z $data ]] && break
    for ((j=0; j<${#data[@]}; j++)); do
        echo -n "["${data[j]}']  '
        done
    echo
done
return
}
#  ----------------------
function askContext(){
echo -e "\nDefines context settings for the web with NGINX:\n"$LINE$LINE
echo " · Use or not the server's public IPr, "
echo " · Use or not the domain name and subdomains"
echo " · A single file of error styles or multiple files for each domain and subdomain."
echo " · Creation of the directory structure and files from the root '/var/www"
echo " · Creation of the web configuration files for NGINX in the directory '/app/nginx'"
echo " · Configure backup copies with a WebDav server"
echo "You can also edit the configuration file [nano context.sh] and, additionally, add domains, IP, ..."
echo -e $LINE$LINE"\nWeb config options in line orders:" 
echo "(all in the same line):"
echo $LINE
echo "    <nameMainDomain>.<extension> <subdomain> ...  [NOIP] [ERRORLOCAL]"
echo
echo "    [x]  Cancel & Return"
echo -e $LINE$LINE 
}
#  ---------------------------------------------------------
# Initial issues
function initialIsues(){
[ ! -d ./.startup ] && mkdir -p ./.startup
cd ./.startup
}
#  -----------------------------
function finalIssues(){
# final issues
echo -e "\n\t\tFinal issues...\n"
cd ..
}
#  ---------------------------------------------------------
# Download git files
function downloadGit(){
file=(start.sh setupServer.sh startup.sh context.sh nginxConfig.sh setupDav.sh letsencrypt.sh nginxStart.sh sslConfig.sh test.sh)
echo -en 'Create the <./startup> directory for the shell files and copy git files (skip if file exist):\n  > ' 
for ((i=0; i<${#file[@]}; i++)); do
    [[ -f ./ ]] && continue
    [[ -f ./${file[i]} ]] && continue
    echo -n '<'${file[i]}'> : '
    wget -q https://raw.githubusercontent.com/app2linux/webDebian/master/${file[i]} -P ./
    chmod +x ./${file[i]}
    done
echo
echo $LINE$LINE
return
}
#  ---------------------------------------------------------
# Update nameservers
function updateNameservers(){
RELEASE=$(lsb_release -cs)
#  ----------------------------------
cat /etc/issue
echo $LINE
echo 'Update system: '$(lsb_release -cs)
file="/etc/resolv.conf"
echo -e "\n DNS servers\n"$LINE$LINE
nameServers=("8.8.8.8" "1.1.1.1" "9.9.9.9" "208.67.222.222" "8.8.4.4" "149.112.112.112" "208.67.220.220")
for name in ${nameServers[*]} ; do
    [[ ! $(sed -n "/^nameserver $name/p;q" $file) ]] && echo 'nameserver '$name >> $file
    done
cat $file
echo $LINE$LINE
return
}
#  ---------------------------------------------------------
# Update sources list
function updateSourcelist(){
file='/etc/apt/sources.list'
echo -e 'File to update : '$file
[[ -f $file.old ]] && { echo -e "\n\t<sources.list> already updated.\n"$LINE$LINE; return; }
[[ -f $file && ! -f $file.old ]] && mv $file $file.old
cat <<EOF  > $file
deb http://ftp.debian.org/debian/ $(lsb_release -cs) main contrib non-free
deb-src http://ftp.debian.org/debian/ $(lsb_release -cs) main contrib non-free
deb http://security.debian.org/ $(lsb_release -cs)/updates main contrib
deb-src http://security.debian.org/ $(lsb_release -cs)/updates main contrib
deb http://ftp.debian.org/debian/ $(lsb_release -cs)-updates main contrib non-free
deb-src http://ftp.debian.org/debian/ $(lsb_release -cs)-updates main contrib non-free
deb http://httpredir.debian.org/debian $(lsb_release -cs) main contrib
deb-src http://httpredir.debian.org/debian $(lsb_release -cs) main contrib
EOF
cat $file
echo $LINE$LINE
return
}
#  ---------------------------------------------------------
# contextConfig
function contextConfig(){
clear
if $(grep -q verifiedContext=true context.sh); then 
    viewContext
    echo -e $LINE$LINE"\n<context.sh> already configured. To change, delete the file first ...\n"$LINE$LINE
    echo -en "\t"; read -rsn1 -p "Press a key to continue  >  " key
else
    while true; do
        askContext
        read -p "   > " lineOrder
        if [[ $lineOrder =~ ^(x|X) ]]; then
            echo
            exit 
        else
            echo -e "\n"$LINE$LINE"\n\nModification of the configuration file"
            ./startup.sh $lineOrder
        fi
        valor=$?
        [[ "${valor}" == 1 ]] && break
    done
fi
echo 
return
}
#  ---------------------------------------------------------
# Create files & folders for www and nginx
function updateWeb(){
echo -e "\n\nCreate files & folders for www and nginx"
echo -e $LINE$LINE 
if $(grep -q folderCreated=true context.sh); then 
    echo -e "\n >  Files & folders already configurated."
    echo -e   "    Delete first files & folders: [ "$wwwFolder" | "$appFolder" ]\n"
else
    ./nginxConfig.sh
    sed -ie "s/^export folderCreated.*$/export folderCreated=true/g" context.sh
fi
echo -e $LINE$LINE 
echo -en "\t"; read -rsn1 -p "Press a key to continue  >  " key
return
}
#  ---------------------------------------------------------
# SSL configuration
function configSSL(){
echo -e "\n\n"$LINE$LINE
ssl=$(sed -e '/^export SSL=/ !d' context.sh); ssl=${ssl:12:-1}
if [ ! -z $ssl ]; then
	echo -e "\n\t SSL/TLS already configured with $ssl\n\n"$LINE$LINE 
    echo -en "\t"; read -rsn1 -p "Press a key to continue  >  " key
else
    source ./context.sh
    domains=
    for ((i=1; i<${#context[@]}; i++)); do
        data=(${context[i]:1:-1})
        [[ -z $data ]] && break
        domains+=${data[0]}" "
        done
    while true; do
        clear
        echo -e "\n"$LINE$LINE"\nDefine LetsEncrypt options:\n"$LINE 
        echo "    [email=<myEmail>] [domains={<domainName> <domainName>}] [sslOn]"
        echo
        echo "LetsEncrypt registration email is optional"
        echo "If the domain options are empty, the default Domains are used:"
        echo "    {"$domains"}"
        echo "sslOn > config ssl on domains"
        echo "    [x]  Continue without ssl config"
        echo -e $LINE$LINE 
        read -p "   > " lineOrder
        [[ $lineOrder =~ ^(x|X|c|C) ]] && break
        [[ ! ${lineOrder} = *"domains="* ]] && lineOrder+=" domains={"${domains:0:-1}"}"
        ./letsencrypt.sh ${lineOrder}
        valor=$?
        [[ "${valor}" == 1 ]] && break
        done
    echo
    fi
return
}
#  ---------------------------------------------------------
# dav configuration: backup of data server: config & start
function configDav(){
dav=$(sed -e '/^export DAVconfig=/ !d' context.sh); dav=(${dav:18:-1})
if [[ -n "$dav" ]]; then
	echo -e "\n\n"$LINE$LINE"\n\n\t Dav backup already configured\n\n"$LINE$LINE
    echo -en "\t"; read -rsn1 -p "Press a key to continue  >  " key
else
    while true; do
        clear
        echo
        echo -e "\n"$LINE$LINE"\nDefine backup parameters:\n(dav & user & pw needed):\n"$LINE 
        echo -e "    dav=<davServer> user=<davUser> pw=<davPw> [dir=<dir2backup>]"
        echo -e "\n    (defaul dir or empty option is nameServer)"
        echo -e "    [x]  Continue without backup config\n"$LINE$LINE 
        read -p "   > " lineOrder
        [[ $lineOrder =~ ^(x|X|c|C) ]] && break
        ./setupDav.sh $lineOrder
        valor=$(echo "$?")
        [[ "${valor}" == 1 ]] && break
        done
    echo -e "\n"$LINE$LINE
    echo -en "\t"; read -n 1 -s -r -p "Press any key to continue  > "
    fi
echo
return
}
#  ---------------------------------------------------------
# Start nginx server
function startNginx(){
[[  -n "$(docker ps -q -f status=running -f name=^/nginx$)" ]] && { echo -e "\n"$LINE$LINE"\n\tDocker container already running.\n"$LINE$LINE; return; }
clear
echo -e '\nStart docker nginx server\n'$LINE
./nginxStart.sh
echo -e "\n"$LINE$LINE"\nFinished installation ...\n"
echo -en "\n\t"; read -rsn1 -p "Press a key to continue  >  " key
}
#  ---------------------------------------------------------
# Main process
#
clear 
echo -e "\nAutomatic install & config & start server and web server.\n"$LINE$LINE
#  -----------------------
configFunctions=(initialIsues downloadGit updateSourcelist ./setupServer.sh contextConfig updateWeb configSSL configDav startNginx finalIssues)
for process in ${configFunctions[*]} ; do
    $process
    done
#  ---------------------------------------------------------
# Modify setup.sh file (this file)
sed -i '8,$d' setup.sh
cat <<'EOF' >> setup.sh
cd .startup
./start.sh
cd ..
exit
EOF
exit
