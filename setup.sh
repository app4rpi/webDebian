#!/bin/bash
# This script has been tested on Debian 8 Jessie image
#
# chmod +x ./setup.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
#  ---------------------------------------------------------
LINE="---------------------------------------"
lineOrder="${@,,} "
#  ---------------------------------------------------------
clear 
echo -e "#\nAutomatic install & config & start server and web server."
echo -e '# '$LINE$LINE
#  ---------------------------------------------------------
# Initial issues
#  ---------------------------------------------------------
# Config system
# setup server
#./setupServer.sh
#  ---------------------------------------------------------
# startup
echo "Defineix paràmetres del context de la web amb NGIX:"
echo " · Ús o no de la IP pública del servidor, "
echo " · Ús o no del nom de domini y subdominis"
echo " · Un únic arxiu d'estils d'errors o múltiples arxius per a cada domini y subdomini."
echo " · Creació de l'estructura de directoris i arxius a partir de l'arrel '/var/www'"
echo " · Creació dels arxius de configuració de la web per a NGINX al directori '/app/nginx'"
echo " · Configurar còpies de seguretat a un WebDav server"
echo "També es podrà editar l'arxiu de configuració [nano context.sh] i, a més, afegir dominis, IP,..."
echo $LINE$LINE
echo "Web config options in line orders:" 
echo "(all in the same line):"
echo "----------------------------------"
echo "    <nameMainDomain>.<extension> <subdomain> <subdomain> <...> \ "
echo "        [NOIP] [ERRORLOCAL] \ "
echo
echo "    [x]  Cancel & Return"
echo -e $LINE$LINE 
read -p "   > " lineOrder
#[[ $lineOrder -ne "x" ]] && echo be || echo surt

#./startup.sh $lineOrder
#  ---------------------------------------------------------
echo
echo -e $LINE$LINE 
echo "Defineix SSL:"
#  ---------------------------------------------------------
echo
echo -e $LINE$LINE 
echo "Defineix copia de seguratat:"
echo "(tots obligatoris):"
echo "----------------------------------"
echo "    [dav=<davServer>] [user=<davUser>] [pw=davPw]"
echo
echo "    [x]  Cancel & Return"
echo -e $LINE$LINE 
read -p "   > " lineOrder
#[[ $lineOrder -ne "x" ]] && echo be || echo surt
#  ---------------------------------------------------------
# Create files & folders for www and nginx
# nginxConfig
#  ---------------------------------------------------------
# final issue
sed -i '8,$d' setup.sh
#sed -ie "s/^# chmod +x.*$/cd startup; start.sh; cd ..;/" setup.sh
cat <<'EOF' >> setup.sh
cd startup
start.sh
cd ..
exit
EOF
exit
