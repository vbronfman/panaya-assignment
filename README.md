# Tanaya-assignment
Tech test for Panaya company

##The solution
Makes use of docker engine to deploy the stack. 
Deploys MySQL DB , initialises table and assignes read-only access for user "report"
Builds multistaged image:
  - first based python and run script to fetch data from DB and build file with results
  - second builds nginx and copies file with DB data as default page.

Container of nginx exposes on localhost:9980 

##Usage:
git clone ...
cd panaya_assignment
./env-manager.sh up

Arguments:
[up|UP] - start mysqldb and webserver stack;
[ down|DOWN ] - stop and remove the stack 
[ down|DOWN ] - deploy - rebuilds and restarts webserver  "

_NOTE
I've started with pure docker solution hence there is below script.
./env-manager-docker.sh starts pure docker environment: builds local images and run containers.
My there recent experience with docker compose is three years ago so it took me a little while. For same reason I've ran into 
peculiar troubles with docker compose while tried to unv env variables for passwords_

