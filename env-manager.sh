#!/bin/env bash

# Straightforward approach - just in sake to spare time. Due the same reason there is less validations than it should be 
# env up/down, image rebuild
# Known issues:
#  failure to build of webserver:  python fails to connect DB my servicename but my host IP only.
#

set -e #trigger failue at first error; 

MODE==${1} # up, down, rebuild
DBNAME=${2:-"DB"}
# sort of security precaution.
MYSQL_ROOT_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32 )
DB_PORT=3306
NGINX_PORT=9980
MYSQL_READ_ONLY_USER="report"

#DBHOST='172.19.244.87'
#grabbed here https://stackoverflow.com/questions/21336126/linux-bash-script-to-extract-ip-address
DBHOST=$(ip route get 8.8.8.8| grep src| sed 's/.*src \(.* \)/\1/g'|cut -f1 -d ' ')

envUp(){
    docker compose up -d mysqldb 
    docker compose build --build-arg OUTFILE=$(date +%s) --build-arg DBHOST=${DBHOST}  webserver
    docker compose up -d

}    

deployPython(){
docker compose  build --build-arg OUTFILE=$(date +%s).html --build-arg DBHOST=${DBHOST} webserver
docker compose up -d webserver
}

envDown(){
    docker compose down
}


case "${1,,}" in  # double comma to lowercase

"up")  echo "Going up"
    envUp
    #deployPython
    ;;
"down")  echo  "Going down"
    envDown
    ;;
"deploy")  echo  "Build anew image of webserver and start"
    deployPython
    ;;
*) echo "My don't know what to do"
   ;;
esac

