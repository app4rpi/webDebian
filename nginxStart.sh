#!/bin/bash
# This script has been tested on Debian 8 Jessie image
# chmod +x ./nginxStart.sh
#  ---------------------------------------------------------
if [ "$EUID" -ne 0 ]; then echo "Must be root"; exit; fi
LINE="---------------------------------------"
#  ---------------------------------------------------------
echo -e '\nDownload & start Nginx Docker Image: \n'$LINE$LINE
dockerImage=$(sed -e '/^export dockerImage/ !d' context.sh); dockerImage=(${dockerImage:20:-1})
nginxDir=$(sed -e '/^export appFolder/ !d' context.sh); nginxDir=(${nginxDir:18:-1})
webDir=$(sed -e '/^export wwwFolder/ !d' context.sh); webDir=(${webDir:18:-1})
containerName="nginx"

[[ -z "$dockerImage" ]] && { echo -e "\n\tDocker image not specified. \n\n\tReview the configuration.\n\tUse the maintenance options to launch the Nginx docker image."; exit 0; }
echo -e "Docker image = [ "$dockerImage" ]"
echo -e "Config dir   = [ "$nginxDir" ]"
echo -e "Web dir      = [ "$webDir" ]"
echo -e "Container    = [ "$containerName" ]\n"$LINE
if [[ -z $(docker images -q $dockerImage) ]]; then
    echo -e "\tDocker image does not exist.\n\tDownload image from DockerHub...\n"
    docker push $dockerImage
    [[ -z $(docker images -q $dockerImage) ]] && { echo -e "\n\tUnavailable docker image. Trial start docker finished.\n\tUse maintenance options to start docker nginx image"; exit 0;}
fi
echo -e "\n[ "$dockerImage" ]  already downloaded ... "
if [[ -n "$(docker ps -q -f status=running -f name=^/${containerName}$)" ]]; then
    echo -e "\t[ ${containerName} ] container exists.\n\tStop & delete container"
    docker stop ${containerName} && docker rm ${containerName}
fi
echo -e "\tStarting container [ ${containerName} ] ..."
docker run -d --restart always --net=host -v ${webDir}:/var/www/ -v ${nginxDir}:/etc/nginx/conf.d/ --name ${containerName} ${dockerImage}
#docker run -d --restart always --net=host -v /var/www:/var/www/ -v /app/nginx:/etc/nginx/conf.d/ --name nginx app2linux/nginx2ssl:latest
exit
