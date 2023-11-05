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

[ deploy ] - deploy - rebuilds and restarts webserver  


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


## TODO
In a way to customise the solution the way to add the following to the above system:
1. GIT
  Manage repository for source code of the solution. 
  Git should be single source of truth: source from git should effectively overright any drift done by manual changes.

2. Jenkins
   - Current Jenkins pipeline needs to be added proper tests . 
   - There is a way to employ Multibranch pipeline to automate build triggering upon merge.

3. Local Docker repository (if I get it properly) 
  For the moment the solution makes no use of Docker repository whatsoever. 
  
  Have to amend with management of images:
  - tagging - like  '${git rev-parse HEAD} for instance
  - validation and security check
  - signing
  - push to repository
  
  Suggested  Docker repository either managed like AWS ECR or Artefactory, Nexus.

4. CI \ CD
  CI is intended to build, validate and test images of the solution. Integration test involves deployment of containers. Once tests yeilded success - images are uploaded to artifactory repository. 

  CI job is triggered by merge into main trank, PR request or on schedule. 


  CD is triggered upon upload of images into archefactory repository. 
   
  For the solution is container based it can be deployed into managed container runtime, like AWS ECS or into k8s cluster.
