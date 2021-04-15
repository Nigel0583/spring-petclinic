pipeline {
environment {
        imagename = "nigel0582/pet_clinic_2"
        registryCredential = 'dockerhub'
        dockerImage = ''
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
           stage('Building image') {
                 steps{
                   script {
                     dockerImage = docker.build imagename
                   }
                 }
               }
               stage('Deploy Image') {
                 steps{
                   script {
                     docker.withRegistry( '', registryCredential ) {
                       dockerImage.push("$BUILD_NUMBER")
                        dockerImage.push('latest')

                     }
                   }
                 }
               }
               stage('Remove Unused docker image') {
                 steps{
                   sh "docker rmi $imagename:$BUILD_NUMBER"
                    sh "docker rmi $imagename:latest"

                 }
               }
    }
    post {
        always {
            cleanWs()
        }
    }
}
