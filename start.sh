# This script has been tested on Debian 8 Jessie image
#
# chmod +x ./start.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="---------------------------------------------"
lineOrder="${@,,}"
#
