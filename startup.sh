#!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./startup.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="-----------------------------------------------"
lineOrder="${@,,}"
#  ----------------------------------
function isCorrect(){
while true; do  read -r -p "Are all correct & continue? [Y/n] " input
  case $input in 
	[yY][eE][sS]|[sS][iI]|[yYsS]) break ;;
	[nN][oO]|[nN]) exit 1 ;; 
  	*) echo -n  "Invalid input...  ->   " ;;
 esac
done
return 1
}
#  ----------------------------------
function finalissues(){
echo -e 'Final issues ... '
return 1
}
#  ----------------------------------
function initialissues(){
echo -e "#\nStart install & config server."
echo -e '# '$LINE$LINE
[[ ${#lineOrder} -eq 0 ]] && echo -e 'Line orders usage & options:\n   ./start.sh [NOIP] [ERRORLOCAL] <nameMainDomain>.<extension> <subdomain> <subdomain> <...>\n# '$LINE$LINE
echo -en '  Initials issues: · Line orders info: '
[[ -z "${lineOrder}" ]] && echo -e "<none>" || echo -e ${lineOrder[@]}
echo -e '# '$LINE$LINE
IP4=$(ifconfig eth0 | grep "inet addr" )
IP4=(${IP4//"inet addr:"})
echo -n 'Server  IP4: ' $IP4
IP6=$(ifconfig eth0 | grep "inet6 addr" )
IP6=(${IP6//"inet6 addr:"})
echo '   |   IP6: ' $IP6
echo -e '# '$LINE$LINE
#
MAINIP4=$IP4
[[ ${lineOrder} = *"noip"* ]] && { MAINIP4=""; lineOrder=${lineOrder//'noip'/}; }
MAINIP4=""
echo -n 'Main IP: '
[[ -z "$MAINIP4" ]] && echo -e "<none>" || echo -e $MAINIP4
[[ ${lineOrder} = *"errorlocal"* ]] && { ERRORLOCAL=true; lineOrder=${lineOrder//'errorlocal'/}; } || ERRORLOCAL=false
if [[ ${lineOrder} = *"."* ]]; then
	ext=${lineOrder//*./};ext=${ext// */}
	dom=${lineOrder//.*/};dom=${dom//* /}
	domain=$dom.$ext
	lineOrder=${lineOrder//$domain/}
	[[ -z $dom || -z $ext ]] && { MAINDOMAIN=""; lineOrder=''; } || MAINDOMAIN=$domain
   else
	MAINDOMAIN=""
   fi
echo -n 'Main domain: '
[[ -z "$MAINDOMAIN" ]] && echo -e "<none>" || echo -e $MAINDOMAIN
echo -en 'Subdomains: ' 
[[ -z $lineOrder ]] && echo -e "<none>" || { SUBDOMAINS=${lineOrder}; echo -e ${SUBDOMAINS}; } 
echo -en "Error page style [error.css]: "
if [[ $ERRORLOCAL = true ]]; then
	echo "Configurable style for each domain in the local directory './css'"
	lineOrder=( ${lineOrder[@]//"errorlocal"/} )
	else
	echo "Unique style for all domains and subdomains in '/error/' directory"
fi
echo -e '# '$LINE$LINE
return 1
}
#  ----------------------------------
function configContext(){
echo -en '<context.sh> config ... '
file='context.sh'
[[ ! -f ${file} ]] && { echo "Error: Required file "${file}" not exist!"; exit 1; }
[[ -f $file && ! -f "${file%.sh}".old ]] && cp "${file}" "${file%.sh}".old
verifiedContext=$(sed -e '/^export verifiedContext/ !d' $file)
verifiedContext=( ${verifiedContext:23} )
[[ ${verifiedContext} = true ]] && echo "Data already validated" || echo "Data to be validated"
temp1='export mainDomain="'$MAINDOMAIN'"'
echo $temp1
temp2='export mainIP="'$MAINIP4'"'
echo $temp2
colors=$(sed -e '/color=/ !d' $file)
colors=( ${colors:7:-1} )
random=$(date +%4N);random=${random:3};
MAINCOLOR=${colors[$random]}
temp3="export mainColor="$MAINCOLOR
echo $temp3
#
echo "# SubDomains data>"
tempSub=( ${SUBDOMAINS} )
declare -a  SUBDOMAINS
for ((i=0; i<${#tempSub[@]}; i++))
	do
	temp='"('${tempSub[i]}.$MAINDOMAIN" '"$MAINIP4"' "${tempSub[i]}" "${tempSub[i]}Site" "${colors[$random+$i+1]}" "mainSite')"'
	SUBDOMAINS+=("$temp") 
	echo $temp
	done
echo -e '# '$LINE$LINE
#
#Confirma
isCorrect
#
sed -ie "s/^export mainDomain.*$/${temp1}/g" $file
sed -ie "s/^export mainIP.*$/${temp2}/g" $file
sed -ie "s/^export mainColor.*$/${temp3}/g" $file
[[ -n "$MAINDOMAIN" ]] && sed -ie "s/(''/($MAINDOMAIN/g" $file
[[ -n "$MAINIP4" ]] && sed -ie "s/'' html/'$MAINIP4' html/g" $file
sed -ie "s/'')/$MAINCOLOR)/g" $file
for ((i=0; i<${#SUBDOMAINS[@]}; i++))
	do
	sed -i -e '0,/^"()"/{s/^"()"/'"${SUBDOMAINS[i]}"'/}' $file
	done
sed -ie "s/^export verifiedContext.*$/export verifiedContext=true/g" $file
sed -ie "s/^errorStyleLocal.*$/export errorStyleLocal=${ERRORLOCAL}/g" $file
echo "Saved data"
return 1
}
#  ----------------------------------
# 
MAINIP4=''
MAINDOMAIN=""
SUBDOMAINS=""
ERRORLOCAL=false
clear
initialissues
configContext
finalissues
exit
