#!/bin/bash
# This script has been tested on Debian 8 Jessie image
#
# chmod +x ./setup.sh
#
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
echo -e "Start install & config server."
ifconfig eth0 | grep inet | awk '{ print $2 }'
#  ---------------------------------------------------------
RELEASE=$(lsb_release -cs)
#  ---------------------------------------------------------
function updateSystem(){
cat /etc/issue
echo "#  ----------------------------------"
echo 'Update & Upgrade system; '
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
}
#  ----------------------------------
function installFirewall(){
echo "#  ----------------------------------"
echo 'Install && config Firewall ... '
[[ $(dpkg --get-selections ufw) ]] && { echo "Already installed";  exit 1;}
apt-get install -y ufw
ufw enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw status verbose
echo 'fw installed'
echo '----------------------------'\n
return 1
}
#  ----------------------------------------
function installGit(){
echo "#  ----------------------------------"
echo 'Install git ... '
[[ $(dpkg --get-selections git) ]] && { echo "Already installed";  exit 1;}
apt-get install git
return 1
}

#  ----------------------------------
function installDocker(){
echo "#  ----------------------------------"
echo 'Install docker ... '
[[ $(dpkg --get-selections docker-ce) ]] && { echo "Already installed";  exit 1;}
apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt-get update
apt-get -y install docker-ce
systemctl enable docker
return 1
}
#  ----------------------------------
function finalissues(){
echo 'Final issues ... '
return 1
}
#  ---------------------------------------------------------
appUsables=(update ufw docker git ending)
for app in ${appUsables[*]} ; do
case  $app  in
    update) updateSystem ;;
    ufw) installFirewall ;;
    git) installGit ;;
    docker) installDocker ;;
    ending) finalissues ;;
    *) echo 'Unable to install [ '$app' ]. Attempt: sudo apt-get install '$app;;
esac
done
echo -e "\nAll done! "
#
exit 0
