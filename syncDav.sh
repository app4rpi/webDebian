#!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./syncDav.sh
#
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
echo -e "Start install & config server."
webdav="https://dav.box.com/dav"
user="user"
pw="password"
FILE="/etc/davfs2/secrets"
POINT='/mnt/dav'
BACKUPDIR="/backup/mydomain"
DIR2SYNC=(/app /var/www /etc/letsencrypt)
#  ---------------------------------------------------------
[[ $(dpkg --get-selections davfs2) ]] && echo "davfs2 installed" || apt-get -y install davfs2
[[ ! -d ${POINT} ]] && mkdir -p ${POINT}
LINE="# personal webdav, nextcloud application password\n/mnt/dav "$user" "$pw
LINE+="\n# older versions used URL, it is equivalent for compatibility reasons\n"
LINE+="#"$webdav" "$user" "$pw
[[ ! -f ${FILE} ]] && touch -p ${FILE}
[[ -z "$(grep "$POINT" "$FILE")" ]] && echo -e $LINE >> ${FILE}
mount -t davfs -o noexec ${webdav} ${POINT}
[[ ! -d ${POINT}/${BACKUPDIR}/ ]] && mkdir -p ${POINT}/${BACKUPDIR}/
[[ ! -d ${POINT}/${BACKUPDIR}/ ]] && { echo 'Unable Backup Dir'; exit; }
for DIR in ${DIR2SYNC[*]} ; do
    [[ -d ${DIR} ]] && rsync -rPz ${DIR} ${POINT}/${BACKUPDIR}/ || echo ${DIR} " not exist!"
done
umount ${POINT}
exit
