#!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./setupDav.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="-------------------------------------------------------"
lineOrder="${@}"
#  ---------------------------------------------------------
echo -e "\nBackup configuration parameters"
echo $LINE$LINE
echo $lineOrder
[[ ${lineOrder} = *"dav="* ]] && { webDav=${lineOrder//*dav=/};webDav=${webDav// */}; } || webDav=''
echo 'Dav: ' $webDav
[[ ${lineOrder} = *"user="* ]] && { user=${lineOrder//*user=/};user=${user// */}; } || user=''
echo 'Usr: ' $user
[[ ${lineOrder} = *"pw="* ]] && { pw=${lineOrder//*pw=/};pw=${pw// */}; } || pw=''
echo 'Pw : ' $pw
[[ ${lineOrder} = *"dir="* ]] && { dir=${lineOrder//*dir=/};dir=${dir// */}; } || dir=''
echo 'Dir: ' $dir
echo $LINE$LINE
[[ ! $dir ]] && dir=$mainDomain
if [[ ! $webDav || ! $user || ! $pw || ! $dir ]]; then
    echo -e "   >  Incorrect mandatory parameters"
    echo -e $LINE$LINE"\n\t"
    read -rsn1 -p "  Press any key to continue > "
    echo
    exit 0
fi
#  ---------------------------------------------------------
FILE="/etc/davfs2/secrets"
POINT=/mnt/dav
BACKUPDIR=/backup/$dir
DIR2SYNC=(/app /var/www)
#
[[ ! -d ${backupFolder} ]] && mkdir -p ${backupFolder}
[[ ! -d ${POINT} ]] && mkdir ${POINT}
hostDav=${webDav//*:\/\//};hostDav=${hostDav%/*};
if ! ping -c 1 -W 1 "$hostDav"; then
    echo -e "   >  Server <$hostDav> not available.\n      Select another cloud service for the backup"
    echo $LINE$LINE
    echo
    read -rsn1 -p "  Press any key to continue > "
    echo
    exit 0
fi
#
sed -Ei "0,/^\/mnt\//{s/^\/mnt\//#\/mnt\//}" /etc/davfs2/secrets
sed -Ei "0,/^https:/{s/^https:/#https:/}" /etc/fstab
echo $POINT $user $pw >> /etc/davfs2/secrets
echo $webDav $POINT davfs rw,user,uid=root,noauto 0 0 >> /etc/fstab
temp='export DAVconfig="'$webDav' '"$POINT"' '$user' '$pw'"'
sed -Ei "s|^export DAVconfig.*$|${temp}|g" context.sh
[[ ! -d ${POINT} ]] && mkdir ${POINT}
#
if [[ ! -f syncDav.sh ]]; then
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
fi
./syncDav.sh
exit
