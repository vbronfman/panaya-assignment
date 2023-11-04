#!/bin/env bash

# Uses "docker compose" to manage stack 
# env up/down, image rebuild
# Known limitations/todo:
#   - there is less validations than it should be 
#   - system uses plain credentials - have to implement secrets
#   - there is no validation of DB is up - it would fail "deploy" if it doesn't

set -e #trigger failue at first error; 

MODE==${1} # up, down, rebuild
DBNAME=${2:-"DB"}
# sort of security precaution. :)
MYSQL_ROOT_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32 )
DB_PORT=3306
MYSQL_IMAGE="panaya/mysql:latest"
MYSQL_CONTAINER="db-mysql"
NGINX_CONTAINER="mynginx"
NGINX_IMAGE="panaya/nginxsrv"
NGINX_PORT=9980
MYSQL_READ_ONLY_USER="report"

#DBHOST='172.19.244.87'
#https://stackoverflow.com/questions/21336126/linux-bash-script-to-extract-ip-address
DBHOST=$(ip route get 8.8.8.8| grep src| sed 's/.*src \(.* \)/\1/g'|cut -f1 -d ' ')

runMySQL(){
    if docker image inspect ${MYSQL_IMAGE} >/dev/null 2>&1; then
        echo "Image ${MYSQL_IMAGE}  exists locally. Running container ${MYSQL_CONTAINER}"
    else
        echo "Image ${MYSQL_IMAGE} does not exist locally. Going to build new image of mysql DB and populate tables in ${DBNAME} database"
        set DOCKER_BUILDKIT=1 # to use heredoc feature of Dockerfile
        docker build -t ${MYSQL_IMAGE} -f Dockerfile_MySQL --build-arg="MYSQL_DATABASE=${DBNAME}" --build-arg="MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}" . 
    fi

    #grabbed here https://stackoverflow.com/questions/72326287/how-can-a-script-check-if-a-particular-docker-container-is-running
    if [[ -n $(docker ps -f "name=${MYSQL_CONTAINER}" -f "status=running" -q) ]];then
        echo "Container ${MYSQL_CONTAINER} is running. Won\'t build"
        return
    elif [[ -n $(docker ps -f "name=${MYSQL_CONTAINER}" -q ) ]];then
        echo "Container ${MYSQL_CONTAINER} seems to exist, but not running. Starting..."       
        docker start  ${MYSQL_CONTAINER}
    else 
      echo "Container ${MYSQL_CONTAINER} does not exist. Running..."       
      docker run -d --rm --name ${MYSQL_CONTAINER} -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
        -e MYSQL_DATABASE=${DBNAME} -p ${DB_PORT}:${DB_PORT}  ${MYSQL_IMAGE}
        
    fi
    sleep 10 # wait for DB to start up
}
 

buildWebserver(){
#kill NGINX container; build anew NGINX image; start NGINX container
  [[ -n $(docker ps -f "name=${NGINX_CONTAINER}" -q) ]] &&  docker kill ${NGINX_CONTAINER}
 
  docker build -t ${NGINX_IMAGE} -f ./Dockerfile_NGINX --build-arg="MYSQLUSER=${MYSQL_READ_ONLY_USER}" --build-arg=OUTFILE=$(date +%s) --build-arg DBNAME=${DBNAME} \
    --build-arg="DBHOST=${DBHOST:=host.docker.internal}" . 
  docker run --rm  -d --name ${NGINX_CONTAINER} -p ${NGINX_PORT}:80  ${NGINX_IMAGE}
}

envDown(){
  docker stop ${MYSQL_CONTAINER}
  docker kill ${NGINX_CONTAINER}

}

case "${1,,}" in  # double comma to lowercase

"up")  echo "Going up"
    runMySQL
    buildWebserver
    ;;
"down")  echo  "Going down"
    envDown
    ;;
"deploy")  echo  "Build anew image of webserver"
    buildWebserver
    ;;
*) echo "My don't know what to do"
   ;;
esac
