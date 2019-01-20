!/bin/bash
# This script has been tested on Debian 8 Jessie image
#
# chmod +x ./setup.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="---------------------------------------"
lineOrder="${@,,} "
#  ---------------------------------------------------------
clear 
echo -e "#\nAutomatic install & config & start server and web server."
echo -e '# '$LINE$LINE
echo -e  'Line orders usage & options (all in the same line):'
echo -e   './setup.sh <nameMainDomain>.<extension> <subdomain> <subdomain> <...> \'
echo -e " [NOIP] [ERRORLOCAL] [dav=<davServer>] [user=<davUser>] [pw=davPw]"
echo -e '# '$LINE$LINE
#  ---------------------------------------------------------
echo 'LO : '${lineOrder}
#
echo
echo 'WebDav backup config:'
echo $LINE
[[ ${lineOrder} = *"dav="* ]] && { dav=${lineOrder##*dav=};dav=dav=${dav%% *}; echo 'DAV: '$dav; lineOrder=${lineOrder//$dav /}; } || { dav=""; echo 'WebDav -> not present'; }
[[ ${lineOrder} = *"user="* ]] && { user=${lineOrder##*user=};user=user=${user%% *}; echo 'USR: '$user; lineOrder=${lineOrder//$user /}; } || { user=""; echo 'User -> not present'; }
[[ ${lineOrder} = *"pw="* ]] &&  { pw=${lineOrder##*pw=}; pw='pw='${pw%% *};  echo 'PW : '$pw;  lineOrder=${lineOrder//$pw /}; } || { pw=""; echo 'Password -> not present'; }
echo
echo 'Web server parameters:'
echo $LINE
[[ ${lineOrder} = *"noip"* ]] && { noip='NOIP'; echo 'NOIP -> active'; lineOrder=${lineOrder//'noip'/}; } || { noip=''; echo 'NOIP -> not present'; }
[[ ${lineOrder} = *"errorlocal"* ]] && { errorlocal='ERRORLOCAL'; echo 'ERRORLOCAL -> active'; lineOrder=${lineOrder//'errorlocal'/}; } || { errorlocal=''; echo 'ERRORLOCAL -> not present'; }
if [[ ${lineOrder[@]} = *"."* ]]; then
exten=${lineOrder##*.} ;domain=${lineOrder//.$exten/};
exten=${exten%% *}; domain=${domain##* };
subdomains=${lineOrder//$domain.$exten/};
[[ ! $domain || ! $exten ]] && { domain='';echo 'DOMAIN -> not present'; } || { domain=$domain.$exten; echo 'DOMAIN: '$domain; }
fi
#  ---------------------------------------------------------
echo 'SUBDOMAINS: '${subdomains}
echo $LINE$LINE
while true; do  read -r -p "Are all correct & continue? [Y/n] " input
  case $input in 
	[yY][eE][sS]|[sS][iI]|[yYsS]) break ;;
	[nN][oO]|[nN]) exit 0 ;; 
  	*) echo -n  "Invalid input...  ->   " ;;
 esac
done
#  ---------------------------------------------------------
# Initial issues
#  ---------------------------------------------------------
# Config system
#  ---------------------------------------------------------
# final issues

exit
