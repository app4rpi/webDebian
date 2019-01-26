#!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./setup.sh
# wget wget https://raw.githubusercontent.com/app2linux/webDebian/master/setup.sh
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
echo -e '# '$LINE$LINE
#  ---------------------------------------------------------
# Initial issues
file=(start.sh setupServer.sh startup.sh context.sh nginxConfig.sh setupDav.sh letsencrypt.sh nginxStart.sh test.sh)
echo -en 'Create the <./startup> directory for the shell files and copy git files  : '
[ ! "$(ls -A ./startup)" ] && mkdir -p ./startup 
for ((i=0; i<${#file[@]}; i++)); do
    echo -n '<'${file[i]}'> : '
    [[ -f ./startup/ ]] && continue
    [[ -f ./startup/${file[i]} ]] && continue
    wget https://raw.githubusercontent.com/app2linux/webDebian/master/${file[i]} -P ./startup
    chmod +x ./startup/${file[i]}
    done
echo
[ ! "$(ls -A ./startup)" ] && { rmdir ./startup; exit; }
cd startup
#
#  ---------------------------------------------------------
# Update System
RELEASE=$(lsb_release -cs)
#  ----------------------------------
cat /etc/issue
echo "#  ----------------------------------"
echo 'Update system: '${RELEASE}
# add nameservers
file="/etc/resolv.conf"
echo -e "\n DNS servers\n"$LINE$LINE
nameServers=("8.8.8.8" "1.1.1.1" "9.9.9.9" "208.67.222.222" "8.8.4.4" "149.112.112.112" "208.67.220.220")
for name in ${nameServers[*]} ; do
# echo 'nameserver '$name
#sed -e "\|$name|h; \${x;s|$name||;{g;t};a\\" -e "$name" -e "}" $file
[[ ! $(sed -n "/^nameserver $name/p;q" $file) ]] && echo 'nameserver '$name >> $file
done
cat $file
echo $LINE$LINE
# Update sources list
file='/etc/apt/sources.list'
echo -e 'File to update : '$file
[[ -f $file && ! -f $file.old ]] && mv $file $file.old
cat <<EOF  > $file
deb http://ftp.debian.org/debian/ ${RELEASE} main contrib non-free
deb-src http://ftp.debian.org/debian/ ${RELEASE} main contrib non-free
deb http://security.debian.org/ ${RELEASE}/updates main contrib
deb-src http://security.debian.org/ ${RELEASE}/updates main contrib
deb http://ftp.debian.org/debian/ ${RELEASE}-updates main contrib non-free
deb-src http://ftp.debian.org/debian/ ${RELEASE}-updates main contrib non-free
deb http://httpredir.debian.org/debian ${RELEASE} main contrib
deb-src http://httpredir.debian.org/debian ${RELEASE} main contrib
EOF
#
echo "# -----------"
apt-get -y update
#  ---------------------------------------------------------
# Config system
# setup server
./setupServer.sh
echo -e $LINE"\n\n>  Server already uptated\n"$LINE
read -n 1 -s -r -p "Press any key to continue > "
#  ---------------------------------------------------------
# startup: define context web
clear
if $(grep -q verifiedContext=true context.sh); then 
    echo
    ./context.sh
    echo -e "\n<context.sh> already configured. To change, delete the file first ..."
    echo $LINE$LINE
    isContinue
else
    reLoop=true
    while $reLoop; do
        echo -e "\nDefines context settings for the web with NGINX:"
        echo $LINE$LINE
        echo " · Use or not the server's public IPr, "
        echo " · Use or not the domain name and subdomains"
        echo " · A single file of error styles or multiple files for each domain and subdomain."
        echo " · Creation of the directory structure and files from the root '/var/www"
        echo " · Creation of the web configuration files for NGINX in the directory '/app/nginx'"
        echo " · Configure backup copies with a WebDav server"
        echo "You can also edit the configuration file [nano context.sh] and, additionally, add domains, IP, ..."
        echo $LINE$LINE
        echo -e "\nWeb config options in line orders:" 
        echo "(all in the same line):"
        echo $LINE
        echo "    <nameMainDomain>.<extension> <subdomain> <subdomain> <...> \ "
        echo "        [NOIP] [ERRORLOCAL] \ "
        echo
        echo "    [x]  Cancel & Return"
        echo -e $LINE$LINE 
        read -p "   > " lineOrder
        #./startup.sh $lineOrder
        #./test.sh $lineOrder
        if [[ $lineOrder =~ ^(x|X) ]]; then
            echo
            exit 
        else
            echo -e $LINE$LINE 
            echo -e "\n\nModification of the configuration file"
            ./startup.sh $lineOrder
        fi
        valor=$(echo "$?")
        [[ "${valor}" == 1 ]] && break
        done
fi
#
#  ---------------------------------------------------------
# Create files & folders for www and nginx
echo -e "\n\nCreate files & folders for www and nginx"
echo -e $LINE$LINE 
if $(grep -q folderCreated=true context.sh); then 
    echo -e "\n >  Files & folders already configurated."
    echo -e   "    Delete first files & folders: [ "$wwwFolder" | "$appFolder" ]\n"
else
    ./nginxConfig.sh
    sed -ie "s/^export folderCreated.*$/export folderCreated=true/g" $file
fi
echo -e $LINE$LINE 
read -n 1 -s -r -p "Press any key to continue > "
#  ---------------------------------------------------------
# SSL configuration
echo
echo "Defineix SSL:"
echo -e $LINE
[[ ! -d /etc/letsencrypt ]] && mkdir -p /etc/letsencrypt
./letsencrypt.sh 
echo -e $LINE$LINE 
read -n 1 -s -r -p "Press any key to continue > "
#  ---------------------------------------------------------
# backup of data server: config & start
clear
reLoop=true
while $reLoop; do
    clear
    echo
    echo -e $LINE$LINE 
    echo "Define backup parameters:"
    echo "(all needed):"
    echo -e $LINE 
    echo "    dav=<davServer> user=<davUser> pw=davPw"
    echo
    echo "    [x]  Cancel & Return   [c]  Continue without backup config"
    echo -e $LINE$LINE 
    read -p "   > " lineOrder
    [[ $lineOrder =~ ^(x|X) ]] && exit
    [[ $lineOrder =~ ^(c|C) ]] && break
    ./setupDav.sh $lineOrder
    valor=$(echo "$?")
    [[ "${valor}" == 1 ]] && break
    done
echo
echo -e $LINE$LINE 
read -n 1 -s -r -p "  Press any key to continue > "
echo

#  ---------------------------------------------------------
# Start nginx server
clear
echo
echo 'Start docker nginx server'
echo -e $LINE
./nginxStart.sh
echo -e "\n"$LINE$LINE 
echo -e "\nFinished installation ...\n\n"
#  ---------------------------------------------------------
# final issues
cd ..
#  ---------------------------------------------------------
# Modify setup.sh file (this file)
sed -i '9,$d' setup.sh
cat <<'EOF' >> setup.sh
cd startup
start.sh
cd ..
exit
EOF
exit
