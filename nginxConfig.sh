#!/bin/bash
# This script has been tested on Debian 8 Jessie image
#
# chmod +x ./nginxConfig.sh
#
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
echo -e "Start install & config server."
ifconfig eth0 | grep inet | awk '{ print $2 }'
#
#  ---------------------------------------------------------
source ./context.sh
#  ---------------------------------------------------------
function updateSystem(){
cat /etc/issue
echo "----------------------------"
echo 'Config ...'
}
#  ----------------------------------
function errorFiles(){
echo 'Create error files ... '
#
errorNum=(4xx 5xx 400 401 403 404 405 408)
errorId=('Client error' 'Server error' 'Bad Request' 'Unauthorized' 'Forbidden' 'Not Found' 'Method Not Allowed' 'Request Timeout')
errorTitleAng=('Client error responses' 'Server error responses' 'Bad Request' 'Unauthorized' 'Forbidden' 'Not Found' 'Method Not Allowed' 'Request Timeout')
errorTextAng=("The 4xx class of status code is intended for cases in which the client seems to have erred."
"The server encountered a condition which prevented it from fulfilling the request."
"This response means that server could not understand the request due to invalid syntax."
"Authentication is needed to get requested response."
"Client does not have access rights to the content so server is rejecting to give proper response." 
"Server can not find requested resource." 
"The request method is known by the server but has been disabled and cannot be used." 
"The server timed out waiting for the request.")
errorTitleCat=("Respostes d'errors del client" "Errors de respostes del servidor" "Sol·licitud incorrecta"
"No autoritzat" "Prohibit" "No trobat" "M&egrave;tode no perm&egrave;s" "Temps d'espera esgotat")
errorTextCat=("El codi d'error 4xx sol indicar casos en qu&egrave; el client sembla haver-se equivocat." 
"El servidor ha trobat una situaci&oacute; que li ha impedit complir amb la sol·licitud."
"La petici&oacute; no pot ser completada degut a un error de sintaxi."
"Es requereix autenticaci&oacute; per obtenir resposta a la sol·licitud."
"El client no t&eacute; drets d 'acc&eacute;s a tot el contingut al servidor i ha rebutjant donar resposta adequada."
"El servidor no pot trobar el recurs sol·licitat." 
"El m&egrave;tode de la petici&oacute; &eacute;s conegut pel servidor però no est&agrave; activa i no es pot utilitzar." 
"El servidor no pot trobar el recurs sol·licitat.")
[[ ! -d ${errorDir} ]] && mkdir -p ${errorDir}
for ((i=0; i<${#errorNum[@]}; i++))
do
mainPage='<!DOCTYPE html>\n<html lang="es-ES">\n<head>\n<meta charset="utf-8" />\n
<title>Error '${errorNum[i]}'</title>\n<link type="text/css" rel="stylesheet" href="/errors/style.css" /></head>'
mainPage+='<body>\n<article><div id="one"><div id="dia" class="number">'${errorNum[i]}'</div>\n
<div id="mes">'${errorId[i]}'</div></div><div id="dos">'
mainPage+="<h3>"${errorTitleAng[i]}"</h3><p>"${errorTextAng[i]}"</p>\n
    <p>This page is not available at this moment, we recommend you going to <a href="/">Home page</a>.</p>\n
    <p>If the error persist don't hesitate to <a href='mailto:webmaster@"${mainDomain}"'>contact us</a>.</p>"
mainPage+="<h3>"${errorTitleCat[i]}"</h3><p>"${errorTextCat[i]}"</p>\n
    <p>Aquesta p&agrave;gina no est&agrave; disponible en aquest moment, es recomana anar a <a href="/">la p&agrave;gina d'inici</a>.</p>\n
    <p>Si l'error persisteix, no dubteu en posar-vos en <a href='mailto:webmaster@"${mainDomain}"'>contacte amb nosaltres</a>.</p></div>"
mainPage+="</article></body></html>"
echo -e $mainPage >  ${errorDir}/${errorNum[i]}.html
done
echo '------------------------------------------------------------------------'
cat <<'EOF' > ${errorDir}/style.css
body {background: #5F4B8B;color: #aaa; font-family: "Helvetica Neue",Helvetica,Arial,sans-serif; overflow:hidden}
#one { position: absolute; left: 0px; width: 396px; font-size: 36px; padding-top: 16px; border-right: 1px solid #ffffff; text-align: center; }
#dos { position: relative; left: 439px;  font-size: 16px;padding-top: 8px; width: 696px;  }
#dos p {line-height: 4px;}
#dos h3 {padding: 16px 0  0 0;margin:0;}
#mes {  font-size: 56px; }
.number { font-size: 196px; line-height: 169px; }
article {position: fixed; top: 50%; left: 35%; transform: translate(-50%, -50%);}
object { width: 696px; }
p a, p a:visited {color: #aaa;}
EOF
return 1
}
#  ----------------------------------
function configWeb(){
echo 'Install && config web ... '
for ((i=1; i<${#context[@]}; i++))
do
data=(${context[i]:1:-1})
[[ ! -d $${wwwFolder}/${data[2]} ]] && mkdir -p ${wwwFolder}/${data[2]}
[[ -z $data ]] && break
thisSite='<!DOCTYPE html>\n<html lang="es-ES"><head><meta charset="utf-8" />\n<style>body{background:'
#[[ -n ${data[1]:1:-1} ]] && thisSite+=${data[1]}":"
[[ -n ${data[4]:1:-1} ]] && thisSite+=${data[4]} || thisSite+=${mainColor}
#thisSite+=${data[4]}
thisSite+=';font:bold normal 4em "Arial"}\nh1{color:#ded;margin-top:21%;text-align:center;}</style>\n'
thisSite+="</head><body><h1>"
[[ -n ${data[0]:1:-1} ]] && thisSite+=${data[0]} || thisSite+='Welcome to nginx'
thisSite+="</h1></body></html>"
echo -e $thisSite > ${wwwFolder}/${data[2]}/index.html
cat ${wwwFolder}/${data[2]}/index.html
echo "# ----------------------------"
done

return 1
}
#  ---------------------------------------------------------
function domainConfig(){
echo 'Config server ... '
[[ ! -d ${appFolder} ]] && mkdir -p ${appFolder}
for ((i=1; i<${#context[@]}; i++))
do
data=(${context[i]:1:-1})
[[ -z $data ]] && break
thisSite="server {\nlisten "
[[ -n ${data[1]:1:-1} ]] && thisSite+=${data[1]}":"
thisSite+="80;\nlisten [::]:80;\nserver_name "
[[ -n ${data[0]:1:-1} ]] && thisSite+=${data[0]} || thisSite+="_"
thisSite+=";\ncharset utf-8;\nroot ${wwwFolder}/${data[2]};\nindex index.html index.htm;\n"
thisSite+="# location\ninclude /etc/nginx/errors.conf;\ninclude /etc/nginx/drop.conf;\n}"
echo -e $thisSite > ${appFolder}/${data[3]}.conf
if [ ! -z ${data[5]:1:-1} ]; then 
line2add="location /"${data[0]%%.*}" { alias "${wwwFolder}/${data[2]}"; autoindex off; }"
#sed -ie "s/# location/$line2add/g" ${appFolder}/${data[5]}.conf
sed -i "/# location/i ${line2add}" ${appFolder}/${data[5]}.conf
fi
cat ${appFolder}/${data[3]}.conf
echo "# ----------------------------"
done
}
#  ----------------------------------
function finalissues(){
echo -n 'Final issues ... '
return 1
}
#  ---------------------------------------------------------
appUsables=(update error web domain ending)
for app in ${appUsables[*]} ; do
case  $app  in
    update) updateSystem ;;
    error) errorFiles ;;
    web) configWeb ;;
    domain) domainConfig;;
    ending) finalissues ;;
    *) echo 'Unable to install [ '$app' ]. Attempt: sudo apt-get install '$app;;
esac
done
echo -e "\nAll done! "
#
exit 0
