pipeline {
    agent { 
        label 'any'
         }
   
   environment {
		DOCKERHUB_CREDENTIALS=credentials('dockerhub')
	}

    options { buildDiscarder(logRotator(artifactDaysToKeepStr: '',
     artifactNumToKeepStr: '', daysToKeepStr: '3', numToKeepStr: '5'))
      disableConcurrentBuilds() }
      

    stages {
        
       stage('Setup parameters') {
            steps {
                script { 
                    properties([
                        parameters([
                          

                            string(
                                defaultValue: '001', 
                                name: 'ImageTAG', 
                                trim: true
                            ),

                            string(name: 'WARNTIME',
                             defaultValue: '2',
                            description: '''Warning time (in minutes) before starting upgrade'''),

                             
                         
                          string(
                                defaultValue: 'develop',
                                name: 'Please_leave_this_section_as_it_is',
                                trim: true
                            ),
                        ])
                    ])
                }
            }
        }

     

     //////////////////////////////////
       stage('warning') {
      steps {
        script {
            notifyUpgrade(currentBuild.currentResult, "WARNING")
            sleep(time:env.WARNTIME, unit:"MINUTES")
        }
      }
    }

        
       stage('SonarQube analysis') {
            agent {
                docker {

                  image 'sonarsource/sonar-scanner-cli:4.7.0'
                }
               }
               environment {
        CI = 'true'
        scannerHome='/opt/sonar-scanner'
    }
            steps{
                withSonarQubeEnv('Sonar') {
                    sh "${scannerHome}/bin/sonar-scanner"
                }
            }
        }



stage('build ') {

            steps {
               sh '''
           docker build -t devopseasylearning2021/eric:$ImageTAG .
               '''
            }
        }
       





      stage('Docker Login') {

			steps {
				sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
			}
		}

           
            

     stage('Docker push ') {
            steps {
               sh '''
              docker push devopseasylearning2021/eric:$ImageTAG 
                '''
            }
        }

    


    stage('Deploy with docker ') {
            steps {
               sh '''
               docker rm -f $(docker ps -aq) || true
               docker run -d --name deploy -p 8787:80 devopseasylearning2021/eric:$ImageTAG 
               curl ifconfig.co 
                '''
            }
        }



    }



 
 post {
    always {
      script {
        notifyUpgrade(currentBuild.currentResult, "POST")
      }
    }
    
  }




}







def notifyUpgrade(String buildResult, String whereAt) {
  if (Please_leave_this_section_as_it_is == 'origin/develop') {
    channel = 'development-alerts'
  } else {
    channel = 'development-alerts'
  }
  if (buildResult == "SUCCESS") {
    switch(whereAt) {
      case 'WARNING':
        slackSend(channel: channel,
                color: "#439FE0",
                message: "ODILIA: Upgrade starting in ${env.WARNTIME} minutes @ ${env.BUILD_URL}  Application ODILIA")
        break
    case 'STARTING':
      slackSend(channel: channel,
                color: "good",
                message: "DEV-ODILIA: Starting upgrade @ ${env.BUILD_URL} Application ODILIA")
      break
    default:
        slackSend(channel: channel,
                color: "good",
                message: "DEV-ODILIA: Upgrade completed successfully @ ${env.BUILD_URL}  Application ODILIA")
        break
    }
  } else {
    slackSend(channel: channel,
              color: "danger",
              message: "DEV-ODILIA: Upgrade was not successful. Please investigate it immediately.  @ ${env.BUILD_URL}  Application ODILIA")
  }
}
