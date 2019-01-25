#!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./test.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="-----------------------------------------------"
lineOrder="${@,,}"
#  ----------------------------------
function isCorrect(){
while true; do  read -r -p "Are all correct & continue? [Y/n] " input
  case $input in 
	[yY][eE][sS]|[sS][iI]|[yYsS]) break ;;
	[nN][oO]|[nN]) exit 0 ;; 
  	*) echo -n  "Invalid input...  ->   " ;;
 esac
done
return 1
}
#  ----------------------------------

isCorrect
exit
