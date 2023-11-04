#!/bin/env bash

# Uses "docker compose" to manage stack 
# env up/down, image rebuild
# Known limitations/todo:
#   - there is less validations than it should be 
#   - system uses plain credentials - have to implement secrets
#   - there is some issue with compose dependencies - webserver prone to fail
#     with " line 308, in _open_connection" due DB isn't up yet. "Dependency" and healthcheck doesn't really helps


set -e #trigger failue at first error; 

MODE==${1} # up, down, rebuild
DBNAME=${2:-"DB"}
# sort of security precaution. :)
export MYSQL_ROOT_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32 )
DB_PORT=3306
NGINX_PORT=9980
 
# Development on top of WSL; host.docker.internal doesn't work
# going to use actual IP of docker host 
#DBHOST='172.19.244.87'
#grabbed here https://stackoverflow.com/questions/21336126/linux-bash-script-to-extract-ip-address
DBHOST=$(ip route get 8.8.8.8| grep src| sed 's/.*src \(.* \)/\1/g'|cut -f1 -d ' ')

envUp(){
    docker compose up -d --wait --no-recreate mysqldb 
    sleep 10
    docker compose build --build-arg OUTFILE=$(date +%s) --build-arg DBHOST=${DBHOST}  webserver
    docker compose up -d --force-recreate webserver
}    

deployWebersver(){
    docker compose  build --build-arg OUTFILE=$(date +%s).html --build-arg DBHOST=${DBHOST} webserver
    docker compose up -d webserver
}

envDown(){
    docker compose down
}


case "${1,,}" in  # double comma to lowercase

"up")  echo "Going up"
    envUp
    #deployWebersver
    ;;
"down")  echo  "Going down"
    envDown
    ;;
"deploy")  echo  "Build anew image of webserver and start"
    deployWebersver
    ;;
*) echo "My don't know what to do
        up|UP - start mysqldb and webserver stack;
        down|DOWN - stop and remove the stack 
        deploy - rebuild and restart webserver  "
   ;;
esac

