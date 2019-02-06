#!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./letsencrypt.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
#  ---------------------------------------------------------
LINE="---------------------------------------"
lineOrder="${@} "
#  ---------------------------------------------------------
echo
echo $LINE$LINE
echo -e "\nStart install & config SSL Letsencrypt for a Nginx Docker server."
echo $LINE
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
[[ ! -f ./certbot-auto ]] &&  { wget https://dl.eff.org/certbot-auto -P ./; chmod +x ./certbot-auto; }
[[ ! -f ./letsencrypt-auto ]] && { wget https://github.com/certbot/certbot/raw/master/letsencrypt-auto -P ./; chmod +x ./letsencrypt-auto; }
if [[ -d /etc/letsencrypt/live ]]; then
    echo -e "\nLetsEncrypt certificates already configured\n\n"$LINE
    read -rsn1 -p "Press any key to continue > "
    exit 0
fi
[[ ${lineOrder} = *"email="* ]] && { email=${lineOrder//*email=/};email=${email// */}; } || email=''
echo 'email  : '$email
[[ ${lineOrder} = *"domains="* ]] && { domains=${lineOrder//*domains=[\{|\[]/};domains=${domains//[\}|\]]*/}; } || domains=''
domainList=${domains//,/ };domains=${domains//  / };
domains=${domains//,/ };domains=${domains//  / };
domains=${domains// /, };
echo 'Domains: '${domains[@]}
echo -en "Config SSL domains:"; [[ ${lineOrder} = *"sslon"* ]] && echo 'ssl ON' || echo 'ssl OFF'
echo $LINE$LINE
if [[ ! ${domains[@]} ]]; then
    echo -e "   >  Error: No domains declared ...\n"$LINE$LINE"\n\t"
    read -rsn1 -p "  Press any key to continue > "
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
echo $LINE$LINE
#./letsencrypt-auto certonly --standalone
./certbot-auto certonly --standalone
echo
if [[ -d /etc/letsencrypt/live ]]; then
    temp='export SSL="letsencrypt"'
    echo $temp
    sed -Ei "s/^export SSL=.*$/$temp/g" context.sh
    temp='export SSLemail="'${email}'"'
    echo $temp
    sed -Ei "s/^export SSLemail=.*$/$temp/g" context.sh
    temp='export SSLdomains="'$domainList'"'
    echo $temp
    sed -Ei "s/^export SSLdomains.*$/$temp/g" context.sh
fi
[[ ${lineOrder} = *"sslon"* ]] && ./sslConfig.sh || echo 'ssl not configured on domains'
echo -en "\n\t"
read -rsn1 -p "Press any key to continue > "
echo
exit 1
