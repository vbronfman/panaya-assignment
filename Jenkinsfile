 pipeline {
    agent any
    /* agent { 
        docker {
            image 'python'    
            // Run the container on the node specified at the
                    // top-level of the Pipeline, in the same workspace,
                    // rather than on a new node entirely:
                    reuseNode true
        } 
    }
    */
    options {
        timestamps()
    }
    
    parameters {
        string(defaultValue: "main", description: 'Which branch?', name: 'BRANCH_NAME')
    }
    
    stages {
         stage('Checkout') {
                steps {
            catchError(message: 'Error to clone code occured') {
                git branch: "${BRANCH_NAME}",
                credentialsId: 'githubtoken',
                url: 'https://github.com/vbronfman/panaya-assignment.git'
              /*
                checkout([$class: 'GitSCM',
                    branches: [[name: "origin/${BRANCH_PATTERN}"]],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [[$class: 'LocalBranch']],
                    submoduleCfg: [],
                    userRemoteConfigs: [[
                        credentialsId: '',
                        url: 'https://github.com/bitwiseman/hermann']]])
                        */
                    }                
                }
        }
        
        stage('Code format') {
            steps {
                catchError(message: 'Error Code format checks occured') {
                  sh """ python -m pip install flake8 || echo Failed to install flake8 ;               """  
                 script {
                    def out = sh(returnStdout: true, script: 'flake8 app.py || echo Flak finished with errors')
                     echo "Output: '${out}'"
                }    
               }
            }
        }
                
        stage('Code lint') {
            steps {
                 sh """ python -m pip install pylint || echo Failed to install pylint                """  
                 script {
                    def status = sh(returnStatus: true, script: 'pylint nginx_create_sqlout.py')
                    if (status != 0) {
                        echo "Error: pylint exited with status ${status}"
                    } else {
                        echo "pylint executed successfully"
                    }
                }    
                  
             }
        }
        
        stage('Pytest') {
            agent { docker { image 'python:3.12.0-alpine3.18' } }
            steps {
                sh 'python --version '
                sh 'ls'
             //   sh 'python -m pytest'
            }
        }

        stage ('Integration test') {
            steps {
                sh 'chmod +x ./env-manager-docker.sh && ./env-manager-docker.sh up'
                sh 'curl -s -I http://localhost:9980/'
            }
         
        }
        
        stage ('Clean Up'){
           steps{
                sh './env-manager-docker.sh down'
                echo ' NOTE! down doesn't stop container mysqldb '.
           }
        }
    }
  post {
    always {
     // sh 'docker compose down --remove-orphans -v'
      
      sh 'docker ps'
              // Clean after build
       cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                               [pattern: '.propsfile', type: 'EXCLUDE']])
       
        }
    }
  
}
