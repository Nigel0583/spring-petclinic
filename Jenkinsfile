pipeline {
 environment {
    registry = "nigel0582/pet_clinic_2"
    registryCredential = 'dockerhub'
    dockerImage = docker.build registry + ":$BUILD_NUMBER"
  }
    agent any

        tools {
            maven "MAVEN_HOME"
        }

    stages {
            stage("Build") {
                 agent { label 'WindowsNode' }
                     steps {
                    bat "mvn -version"
                    bat "mvn clean install"
                }
            }

            stage("Test"){
                    steps{
                        bat 'mvn test'
                    }
                    post{
                        always{
                            junit '**/target/surefire-reports/TEST-*.xml'
                        }
                    }
            }

            stage("Deploy"){
                    steps{
                        bat "mvn clean package"
                    }
                    post{
                        success {
                            archiveArtifacts 'target/*.jar'
                        }
                    }
            }
            stage("Build Docker Image"){
                        steps{
                           script {
                                     docker.build registry + ":$BUILD_NUMBER"
                                   }
                        }
            }
             stage("Deploy Image"){
                         steps{
                             script {
                                   docker.withRegistry( '', registryCredential ) {
                                     dockerImage.push()
                                   }
                              }
                         }
              }
    }
    post {
        always {
            cleanWs()
        }
    }
}
