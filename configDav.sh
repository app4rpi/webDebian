#!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./configDav.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="-------------------------------------------------------"
lineOrder="${@}"
#
FILE="/etc/davfs2/secrets"
POINT=/mnt/dav
dir=$mainDomain
BACKUPDIR=/backup/$dir
DIR2SYNC=(/app /var/www)
lineContext=""
lineSystem=""
lineConsole=""
#  ---------------------------------------------------------
echo -e "\n\n"$LINE"\nBackup configuration parameters\n"$LINE
# --------------------------------------------------------------------------
function isOk(){
echo -en "  ::  It's OK?  >  "; 
while IFS= read -rsn1 key; do
    [[ $key =~ ^[YySs]$ ]] && return 1
    [[ $key =~ ^[Nn]$ ]] && return 0
    done
return 1
}
#  ---------------------------------------------------------
function checkPing(){
hostDav=$1
[[ ! ${hostDav} = *"://"* ]] && { echo ' >  unknown host'; return; }	
hostDav=${hostDav//*:\/\//}; hostDav=${hostDav%/*};
if ping -q -c 1 -W 1 "$hostDav"; then
echo '   >  Ok'
return 1
else
    echo -e "   >  Unavalible server $hostDav"
return 0
fi
return
}
#  --------------------------
function checkLine(){
myLine=(${@})
[[ ! ${myLine[@]} ]] && { return 0; }
[[ ! ${myLine[0]} || ! ${myLine[1]} || ! ${myLine[2]} || ! ${myLine[3]} ]] && { return 0; }
[[ ! ${myLine[0]} = *"://"* ]] && { return 0; }
checkPing ${myLine[0]}; ok=$?; [[ ! ok ]]  && { return 0; }
return 1
}
#  --------------------------
function checkLineorder(){
webDav=$1
user=$2
pw=$3
echo -en "Command line's configuration : "
if [[ ! $lineOrder ]]; then
echo '<none>'
elif [[ ! $webDav || ! $user || ! $pw ]]; then
    echo -e "Incorrect parameters"
else
echo -e '\n\tDav: ' $webDav'\n\tUsr: ' $user
echo -e '\tPw : ' $pw'\n\tDir: ' $dir
lineConsole=($webDav' '$POINT' '$user' '$pw)
fi
echo -e $LINE
return
}
#  --------------------------
function createSyncDav(){
    temp="#!/bin/bash\n# \n"
    temp+="# chmod +x ./syncDav.sh\n#  ---------------------------------------------------------\nDIR2SYNC=("
    temp+=${DIR2SYNC[@]}
    temp+=")\nmount ${POINT}\n"
    temp+="if ! mount | grep ${POINT} > /dev/null; then\n   echo 'ERROR: No backup devices'\n   exit\nfi\n"
    temp+="[[ ! -d ${POINT}${BACKUPDIR} ]] && mkdir -p ${POINT}${BACKUPDIR}\n"
    temp+="echo\necho Start backup ...\necho Remote backup dir: ${webDav}${BACKUPDIR}\n"
    temp+="echo '---------------------------------------------------------'\n"
    temp+="[[ ! -d ${POINT}${BACKUPDIR}/ ]] && { echo 'Unable Backup Dir'; exit; }\n"
    temp+="[[ -d /etc/letsencrypt ]] && tar -cvf /app/backup/letsencrypt.tar /etc/letsencrypt\n"
    temp+="for DIR in \${DIR2SYNC[*]} ; do\n\t"
    temp+="[[ -d \${DIR} ]] && rsync -urP -var --progress --delete \${DIR} ${POINT}${BACKUPDIR}/ || echo \${DIR} ' not exist!'\n"
    temp+="done\numount ${POINT}\n"
    temp+='    read -srn1 -p "  Press any key to continue > "'
    temp+="\nexit\n"
    echo -e $temp >> ./syncDav.sh
    chmod +x ./syncDav.sh
    ln syncDav.sh ../backup.sh
return
}
#  --------------------------
function saveConfig(){
myLine=(${@})
echo ${myLine[1]} ${myLine[2]} ${myLine[3]} >> /etc/davfs2/secrets
echo ${myLine[0]} ${myLine[1]} davfs rw,user,uid=root,noauto 0 0 >> /etc/fstab
temp='export DAVconfig="'${myLine[0]}' '"${myLine[1]}"' '${myLine[2]}' '${myLine[3]}'"'
sed -Ei "s|^export DAVconfig.*$|${temp}|g" context.sh
[[ ! -d ${myLine[1]} ]] && mkdir ${myLine[1]}
echo -e ' ::  Saved config'
return
}
#  --------------------------
function removeConfig(){
echo -en '\n'$LINE'\n\tRemove config '
sed -Ei "0,/^\/mnt\//{s/^\/mnt\//#\/mnt\//}" /etc/davfs2/secrets
sed -Ei "0,/^https:/{s/^https:/#https:/}" /etc/fstab
sed -Ei "s|^export DAVconfig.*$|export DAVconfig=\"\"|g" context.sh
return
}
#  --------------------------
function checkContext(){
echo -n "<context.sh> configuration : "
lineContext=$(sed -e '/^export DAVconfig/ !d' context.sh)
lineContext=(${lineContext:18:-1})
if [[ -z $lineContext ]]; then
echo 'None'
else
echo -en "\n\tServer: [ ${lineContext[0]} ]"
echo -e "\n\tUser  : [ ${lineContext[2]} ]\n\tPassw : [ ${lineContext[3]} ]"
# echo -e '\n\t'$lineContext 
#echo ${lineContext[0]} '::'  ${lineContext[1]} '::'${lineContext[0]} '::'${lineContext[1]}
fi 
 echo $LINE 
return
}
#  --------------------------
function checkDavfs2(){
lineDavfs2=( $(sed -e '/^\/mnt\// !d' /etc/davfs2/secrets) )
lineFstab=( $(sed -e '/^https/ !d' /etc/fstab) )
if [[ ${lineFstab[1]} = ${lineDavfs2[0]} ]]; then
echo -e "Current configuration:\n\tServer: [ ${lineFstab[0]} ]"
echo -e "\tUser  : [ ${lineDavfs2[1]} ]\n\tPassw : [ ${lineDavfs2[2]} ]\n"$LINE
lineSystem=(${lineFstab[0]} ${lineFstab[1]} ${lineDavfs2[1]} ${lineDavfs2[2]})
fi
return
}
#  ---------------------------------------------------------
# Main process
[[ ! -d ${backupFolder} ]] && mkdir -p ${backupFolder}
if [[ ! $lineOrder ]]; then
        echo -e "\nDefine backup parameters (in this order):\n"$LINE 
        echo -e "    <davServer> <davUser> <davPw>\n"
        echo -e "    [x]  Continue\n"$LINE 
        read -p "   > " lineOrder
	echo -e '\n'$LINE
fi
checkLineorder $lineOrder
checkContext
checkDavfs2
#echo -en; read -srn1 -p " check  > "; 

checkLine ${lineContext[@]}; q=$?; [[ $q = 0 ]] && lineContext=("")
checkLine ${lineSystem[@]};  q=$?; [[ $q = 0 ]] && lineSystem=("")
checkLine ${lineConsole[@]}; q=$?; [[ $q = 0 ]] && lineConsole=("")

echo 'Config file  => ' ${lineContext[@]}
echo 'System file  => ' ${lineSystem[@]}
echo 'Line orders  => ' ${lineConsole[@]}
L=${lineConsole[@]}; S=${lineSystem[@]};C=${lineContext[@]};

if [[ ${lineConsole[@]} ]]; then
    if [ "$L" == "$S" ]; then
        echo -e $LINE"\n\tConfig files already updated"
    else
        echo -en "\n$LINE\nNew backup config with:\n\t"${lineConsole[@]}"\n> Replace actual system config "
        isOk; ok=$?;  [[ $ok ]] && { removeConfig; saveConfig ${lineConsole[@]}; }
    fi
elif [ "$C" == "$S" ]; then
    echo -e $LINE"\n\tBackup already cofigured"
else
    echo -en $LINE"\nUse <context.sh> parameters:\n\t"$C'\n\nReplace system config'
    isOk; ok=$?;  
    if [[ $ok = 1 ]]; then
	 removeConfig; saveConfig ${lineContext[@]};
    else
        echo -en '\n'$LINE"\nUse System Config parameters:\n\t"$S'\n\nReplace <context.sh> config'
        isOk; ok=$?;  [[ $ok = 1 ]] && { removeConfig; saveConfig ${lineSystem[@]}; }
	echo
    fi
fi
echo -en $LINE'\n'; read -srn1 -p "  Press any key to continue > "; 
exit
