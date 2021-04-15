pipeline {
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
                            bat 'docker build -t nigel0582/pet_clinic_2:2.0.0 .'
                        }
                    }
             stage("Push Docker Image"){
                         steps{
                             withCredentials([string(credentialsId: 'docker-pwd', variable: 'dockerHubPwd')]) {
                                 bat "docker login -u nigel0582 -p ${dockerHubPwd}"
                             }
                             bat 'docker push nigel0582/pet_clinic_2:2.0.0'
                         }
    }
    post {
        always {
            cleanWs()
        }
    }
}
