#!/bin/bash
# This script has been tested on Debian 8 Jessie image
#
# chmod +x ./start.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="-------------------------------------------------------"
#lineOrder="${@,,}"
#
file=(startup.sh setup.sh context.sh nginxConfig.sh syncDav.sh)
#  ---------------------------------------------------------
function loadBashFiles(){
echo -en 'Create the <./startup> directory for the shell files and copy git files  : '
[ ! "$(ls -A ./startup)" ] && mkdir -p ./startup 
for ((i=0; i<${#file[@]}; i++))
do
echo -n '<'${file[i]}'> : '
    [[ -f ./startup/ ]] && continue
    [[ -f ./startup/${file[i]} ]] && continue
    wget https://raw.githubusercontent.com/app2linux/webDebian/master/${file[i]} -P ./startup
    chmod +x ./startup/${file[i]}
    done
echo
[ ! "$(ls -A ./startup)" ] && rmdir ./startup
return 1
}
# --------------------------------------------------------------------------
displayMenu() {
 clear
 echo -e $LINE
 echo -e "       Options       "
 echo -e $LINE 
 echo -e "  1. Update <StartUp> files"
 echo -e "  2. Update server & install ufw firewall, git, Docker,..."
 echo -e "  3. Prepare web server context"
 echo -e "  4. Create web server file & folder structure"
 echo -e "  x. Exit"
 echo -e $LINE 
}
#  ----------------------------------
readOptions(){
 local choice
echo -en "\t"
 read -p "Enter choice -> " choice
#read -n1 -r -p "Press any key to continue..." key

 case $choice in
 1) updateStartUp ;;
 3) prepareContext ;;
 x) exit 0;;
 *) echo -e "${RED}Error...${STD}" && sleep 2
 esac
}
# --------------------------------------------------------------------------
function finalissues(){
echo -e 'Final issues ... '
return 1
}
#  ----------------------------------
function initialissues(){
[[ ! -d ./startup ]] && { echo "<./startup> directory is unable"; exit; }
echo -e 'Initial issues ... '

return 1
}
# --------------------------------------------------------------------------
function prepareContext(){
echo
# read -n1 -r -p "Press any key to continue (x to cancel)..." key
echo $LINE$LINE
echo "Defineix paràmetres del context de la web amb NGIX:"
echo " · Ús o no de la IP pública del servidor, "
echo " · Ús o no del nom de domini y subdominis"
echo " · Un únic arxiu d'estils d'errors o múltiples arxius per a cada domini y subdomini."
echo " · Creació de l'estructura de directoris i arxius a partir de l'arrel '/var/www'"
echo " · Creació dels arxius de configuració de la web per a NGINX al directori '/app/nginx'"
echo "També es podrà editar l'arxiu de configuració [nano context.sh] i, a més, afegir dominis, IP,..."
echo $LINE$LINE
echo "Web config options in line orders:" 
echo "----------------------------------"
echo "·   [<none>] Config with system IP, without <domainName.ext>, 'error.css' style page global"
echo "·   [NOIP] [<nameMainDomain>.<extension>] [<subdomain> <subdomain>] [ERRORLOCAL]"
echo "·   [x]  Cancel & Return"3
echo -e $LINE 
read -p "   > " lineOrder
[[ $lineOrder = "x" ]] && return
cd startup
./startup.sh $lineOrder
cd ..
return 1
}
# --------------------------------------------------------------------------
function updateStartUp(){
echo
echo $LINE$LINE
echo -e 'Update StartUp copia los scripts [ '${file[@]}' ]'
echo -e 'del repositorio git no existentes en el directorio <startup> '
echo
echo "Per fer una restauració dels arxius, es poden borrar des de la consola: "
echo "   rm ./startup/<fileName>"
echo "Per borrar tot el directori i arxius, fer des de la consola d'ordres:"
echo "   rmdir -R -f ./startup"
echo $LINE$LINE
read -n1 -r -p "Press any key to continue (x to cancel)..." key
[[ $key = "x" ]] && return
loadBashFiles
return 1
}
#  ----------------------------------
#
clear
[[ ! -d ./startup ]] && loadBashFiles
initialissues
while true
   do
   displayMenu
   readOptions
   done
finalissues
exit
