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
         stage('checkout') {
                steps {
            catchError(message: 'Error to clone code occured') {
                git branch: 'main',
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
                  sh """ python3 -m pip install flake8 || echo Failed to install flake8 ;               """  
                 script {
                    def out = sh(returnStdout: true, script: 'flake8 app.py || echo Flak finished with errors')
                     echo "Output: '${out}'"
                }    
            }
        }
                
        stage('Code lint') {
            steps {
                 sh """ python3 -m pip install pylint || echo Failed to install pylint                """  
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
        
        stage('Test') {
            steps {
                sh 'python3 '
                sh 'python3 -m pytest'
            }
        }

        stage ('Integration test') {
            steps {
                sh './env-manager.sh up'
                sh 'curl http://localhost:9980/param?query=demo | jq'
            }
         
        }
        
        stage ('Clean Up'){
           steps{
                sh 'echo clean up'
           }
        }
    }
  post {
    always {
     // sh 'docker compose down --remove-orphans -v'
      sh 'docker compose down -v'
      sh 'docker compose ps'
    }
  }
}
