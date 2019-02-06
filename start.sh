#!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./start.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="-------------------------------------------------------"
#  ---------------------------------------------------------
function loadBashFiles(){
file=(start.sh startup.sh setupServer.sh context.sh nginxConfig.sh syncDav.sh)
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
 echo -e "  4. Create web server files & folders structure"
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
 2) setupServer ;;
 3) prepareContext ;;
 4) createStructure ;;
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
#  ----------------------------------
function setupServer(){
echo
echo $LINE$LINE
echo
echo $LINE$LINE
read -n1 -r -p "Press any key to continue (x to cancel)..." key
cd startup
./setupServer.sh
cd ..
read -n1 -r -p "Press any key to continue ..." key
return 1
}
#  ----------------------------------
function createStructure(){
echo
echo $LINE$LINE
echo
echo $LINE$LINE
read -n1 -r -p "Press any key to continue (x to cancel)..." key
cd startup
./nginxConfig.sh
cd ..
read -n1 -r -p "Press any key to continue ..." key

return 1
#!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./start.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="-------------------------------------------------------"
#  ---------------------------------------------------------
function isCorrect(){
while true; do  echo -en "\t"
read -r -p "Are all correct & continue? [Y/n] " input
  case $input in 
	[cC][yY][eE][sS]|[sS][iI]|[yYsS]) return 1 ;;
	[xX][nN][oO]|[nN]) return 0 ;; 
  	*) echo -en  "\tInvalid input...  ->   " ;;
 esac
done
return 1
}
# --------------------------------------------------------------------------
function initialIssues(){
echo -e 'Initial issues ... '
cd .startup
return 1
}
#  ----------------------------------
function finalIssues(){
echo -e '\nFinal issues ... '
cd ..
return 1
}
# --------------------------------------------------------------------------
function downloadGit(){
echo -e '\n'$LINE'\nDownload git files:'
echo -e "\tCopy & overwriting all bash script files except <context.sh>"
echo -e "\tTo modify <context.sh> erase file first\n"$LINE
isCorrect; val=$?;
[[ $val == 0 ]] && return
file=(start.sh setupServer.sh startup.sh nginxConfig.sh setupDav.sh letsencrypt.sh nginxStart.sh sslConfig.sh test.sh)
echo-n "Bash files: "
for ((i=0; i<${#file[@]}; i++)); do
    echo -n '<'${file[i]}'> : '
    wget -q https://raw.githubusercontent.com/app2linux/webDebian/master/${file[i]} -P ./
    chmod +x ./${file[i]}
    done
echo
echo $LINE$LINE
echo -e  "\n\tExit now & restart bash script file \n"
echo -en "\t"; read -n1 -r -p "Press key to continue -> " key
echo
exit
}
#  ----------------------------------
function restartContext(){
echo -e '\n'$LINE'\nDelete <context.sh> config files,'
echo -e "Restore from file or download new file from GitUb\n"$LINE
isCorrect; val=$?;
[[ $val == 0 ]] && return
mv ./context.sh ./context.old
[[ -f context.bak ]] && cp ./context.bak ./context.sh || { wget https://raw.githubusercontent.com/app2linux/webDebian/master/context.sh -P ./; chmod +x ./context.sh; }
echo -e "\tFile <context.sh> restored."
echo -en "\t"; read -n1 -r -p "Press key to continue -> " key
return 1
}
#  ----------------------------------
function viewContext(){
source ./context.sh
echo
echo $LINE$LINE
echo -e "\nEnvironamental variables.\n"$LINE$LINE
echo -e "Main domain:[$mainDomain]   IP:[$mainIP]\n"$LINE
echo -e "\nFolders:  App:[$appFolder]  Backup:[$backupFolder]  www:[$wwwFolder]  Error dir:[$errorDir]"
echo -en "Error style: "
[[ ${errorStyleLocal} = true ]] && echo 'Global' || echo 'Local'
echo -e $LINE$LINE"\n[domain IP workDir nameSite colorSite subDirIn]\n"$LINE
title=(${context[0]:1:-1})
for ((i=1; i<${#context[@]}; i++));  do
    data=(${context[i]:1:-1})
    [[ -z $data ]] && break
    for ((j=0; j<${#data[@]}; j++)); do
    echo -n "["${data[j]}']  '
    done
echo
done
echo $LINE$LINE
echo -en "\t"; read -rsn1 -p "Press key to continue -> " key
return 1
}

# --------------------------------------------------------------------------
updateWeb() {
while true; do
    echo -e "\n"$LINE"\n\tUpdate web config\n"$LINE 
    echo -e "  1. View <context.sh> config files"
    echo -e "  2. Delete <context.sh> config file"
    echo -e "  3. Add main domain & subdomains"
    echo -e "  4. Modify domains & subdomains"
    echo -e "  4. Delete domains & subdomains"
    echo -e "  4. Update files & folders with <context.sh> config"
    echo -e "  x. Exit\n"$LINE
    echo -en "\t"; read -n1 -r -p "Enter choice -> " key
    case $key in
        1) viewContext ;;
        2) restartContext ;;
        x) break ;;
        *) echo -e "${RED} Error...${STD}" && sleep 2 ;;
        esac
    done
return
}
#  ----------------------------------
updateServer() {
while true; do
    echo -e "\n"$LINE"\n\tUpdate & install options\n"$LINE 
    echo -e "  1. Update bash script config files"
    echo -e "  2. Update server & install uninstalled packages"
    echo -e "  x. Exit\n"$LINE
    echo -en "\t"; read -n1 -r -p "Enter choice -> " key
    case $key in
        1) downloadGit ;;
        2) ./setupServer.sh ;;
        x) break ;;
        *) echo -e "${RED} Error...${STD}" && sleep 2 ;;
        esac
    done
return
}
# --------------------------------------------------------------------------
# Main menu
initialIssues
while true; do
    clear
    echo -e $LINE"\n\tOptions\n"$LINE 
    echo -e "  1. Update server & install packages & files"
    echo -e "  2. Update web server config"
    echo -e "  4. Create web server files & folders structure"
    echo -e "  x. Exit\n"$LINE
    echo -en "\t"; read -n1 -r -p "Enter choice -> " key
    case $key in
        1) updateServer ;;
        2) updateWeb ;;
        3) prepareContext ;;
        4) createStructure ;;
        x) break ;;
        *) echo -e "\n\n\t${RED} Error...${STD}" && sleep 2 ;;
    esac
done
#
finalIssues
exit
