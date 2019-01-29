#!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./letsencrypt.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
#  ---------------------------------------------------------
LINE="---------------------------------------"
lineOrder="${@} "
#  ---------------------------------------------------------
clear
echo -e "\nStart install & config SSL Letsencrypt for a Nginx Docker server."
echo $LINE$LINE
#  ---------------------------------------------------------
function isContinue(){
echo
echo -n "[x] Cancel & break     [c] Continue   > "
while true; do  read -rsn1  input
  case $input in 
	[cC]) { echo;break;} ;;
	[xX]) { echo;exit 0;} ;; 
 esac
done
return 1
}
#  ---------------------------------------------------------
# si existeixen certificats, acabar i sortir
if [[ -d /etc/letsencrypt/live ]]; then
	echo -e "\nLetsEncrypt certificates already configured\n"$LINE
	read -n 1 -s -r -p "Press any key to continue > "
	exit 0
	fi
[[ ! -f ./certbot-auto ]] &&  { wget https://dl.eff.org/certbot-auto -P ./; chmod +x ./certbot-auto; }
[[ ! -f ./letsencrypt-auto ]] && { wget https://github.com/certbot/certbot/raw/master/letsencrypt-auto -P ./; chmod +x ./letsencrypt-auto; }
echo $lineOrder
[[ ${lineOrder} = *"email="* ]] && { email=${lineOrder//*email=/};email=${email// */}; } || email=''
echo 'email  : '$email
[[ ${lineOrder} = *"domains="* ]] && { domains=${lineOrder//*domains=[\{|\[]/};domains=${domains//[\}|\]]*/}; } || domains=''
domains=${domains//,/ };domains=${domains//  / };
domains=${domains// /, };
echo 'Domains: '${domains[@]}
echo $LINE$LINE
if [[ ! ${domains[@]} ]]; then
    echo -e "   >  Error: No domains declared ..."
    echo $LINE$LINE
    echo
    read -n 1 -s -r -p "  Press any key to continue > "
    echo
    exit 0
fi
#
file='/etc/letsencrypt/cli.ini'
echo -e "\n"$file 'content\n'$LINE
content="rsa-key-size = 4096"
[[ ! ${email} ]] && content+="\nemail = "$email || "\n#email = "
content+="\npreferred-challenges = http-01\nagree-tos = True\nrenew-by-default = True\n"
content+="domains = "$domains
echo -e $content
echo $LINE$LINE
echo -e "\nStarting install LetsEncrypt certificate ..."
isContinue
#echo -e $content > $file
echo $LINE
#./letsencrypt-auto certonly --standalone
./certbot-auto certonly --standalone
echo $LINE$LINE
echo
./sslConfig.sh
read -n 1 -s -r -p "  Press any key to continue > "
echo
exit 1
