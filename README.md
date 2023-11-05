# Panaya-assignment
Tech test for Panaya company

## The solution
Makes use of docker engine to deploy the stack. 
Deploys MySQL DB , initialises table and assignes read-only access for user "report"
Builds multistaged image:
  - first based python and run script to fetch data from DB and build file with results
  - second builds nginx and copies file with DB data as default page.

Container of nginx exposes on __localhost:9980__ 

## Usage:
git clone ...

cd panaya_assignment

./env-manager.sh up


### Arguments:
[up|UP] - start mysqldb and webserver stack;

[ down|DOWN ] - stop and remove the stack 

[ down|DOWN ] - deploy - rebuilds and restarts webserver  


### Validation
Once _'./env-manager.sh up'_ yeilded success validate the solution as following:
1. Reveal effective password of _'root'_ 
      _docker exec -it mysqldb bash -c 'echo $MYSQL_ROOT_PASSWORD'_


2. Enter mysql DB edployed by solution. Use either MySQL Workbench or :
_docker exec -it mysqldb bash_
_mysql -u root -p_
_mysql>_ 

3. Change table 
SET SQL_SAFE_UPDATES = 0;
set autocommit=1;
update `DB`.`As_company`  set Name="Panaya" where Name="Somethingelse";
commit;

4. Run _./env-manager.sh deploy'_

5. Verify output if http://localhost:9980

__NOTE__
I've started with pure docker solution hence there is below script:

_./env-manager-docker.sh_ It starts pure docker environment: builds local images and run containers.

My there recent experience with docker compose is three years ago so it took me a little while. For same reason I've ran into peculiar troubles with docker compose while tried to unv env variables for passwords

## Jenkins job

Jenkinsfile is pipeline definition for build and mockup tests with intention to validate: lint, format, pytest and Integration_test.
Pipeline clones repo and runs _./env-manager-docker.sh up_ to test the solution.

Jenkins job tested Jenkins in docker.

### Known issues
There was an issue of access denied of report@localhost' in step of 
RUN python nginx_create_sqlout.py --mysqluser report --out 16... 
while builds image of Nginx:
_01:50:23  #7 0.763 _mysql_connector.MySQLInterfaceError: Access denied for user 'report'@'172.17.0.1' (using password: YES)_

As workaround altered report user in DB to set new password "report". By rerun of pipeline issue doesn't recure.

