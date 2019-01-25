#!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./setupDav.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="-------------------------------------------------------"
lineOrder="${@,,} "
FILE="/etc/davfs2/secrets"
POINT=/mnt/dav
BACKUPDIR="/backup/"$mainDomain
DIR2SYNC=(/app /var/www /etc/letsencrypt)
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
echo $LINE$LINE

if [[ ! $webDav || ! $user || ! $pw ]]; then
    echo -e "   >  Incorrect mandatory parameters"
    echo $LINE$LINE
    echo
    read -n 1 -s -r -p "  Press any key to continue > "
    exit 0
fi
#
hostDav=${webDav//*:\/\//};hostDav=${hostDav%/*};
if ! ping -c 1 -W 1 "$hostDav"; then
    echo -e "   >  Server <$hostDav> not available.\n      Select another cloud service for the backup"
    echo $LINE$LINE
    echo
    read -n 1 -s -r -p "  Press any key to continue > "
    echo
    exit 0
fi
#
#dirDav=${webDav//*:\/\//};dirDav=${dirDav%.*};[[ ${dirDav} = *"."* ]] && dirDav=${dirDav##*.}Dav;
if $(grep -q ^https: /etc/davfs2/secrets); then echo nameserver 1.1.1.1
    sed -ie "0,/^https:/{s/^https:/#https:/}" /etc/davfs2/secrets
    sed -ie "0,/^https:/{s/^https:/#https:/}" /etc/fstab
fi
echo $webDav $user $pw >> /etc/davfs2/secrets
echo $webDav $POINT davfs rw,user,uid=root,noauto 0 0 >> /etc/fstab
#
if [[ ! -f syncDav.sh ]]; then
    temp="#!/bin/bash\n# \n"
    temp+="# chmod +x ./syncDav.sh\n#  ---------------------------------------------------------\nDIR2SYNC=("
    temp+=${DIR2SYNC[@]}
    temp+=")\nmount ${POINT}\n"
    temp+="if ! mount | grep ${POINT} >/dev/null; then\n   echo 'ERROR: No backup devices'\n   exit\nfi\n"
    temp+="[[ ! -d ${POINT}${BACKUPDIR}/ ]] && mkdir -p ${POINT}${BACKUPDIR}/\n"
    temp+="echo\necho Start backup ...\necho Remote backup dir: ${webDav}${BACKUPDIR}\n"
    temp+="echo '---------------------------------------------------------'\n"
    temp+="[[ ! -d ${POINT}${BACKUPDIR}/ ]] && { echo 'Unable Backup Dir'; exit; }\n"
    temp+="for DIR in \${DIR2SYNC[*]} ; do\n"
    temp+="    [[ -d \${DIR} ]] && rsync -rPz \${DIR} ${POINT}${BACKUPDIR}/ || echo \${DIR} ' not exist!'\n"
    temp+="done\numount ${POINT}\nexit\n"
    echo -e $temp >> ./syncDav.sh
    chmod +x ./syncDav.sh
    ln syncDav.sh ../backup.sh
fi
./syncDav.sh
exit

