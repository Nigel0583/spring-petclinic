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
           stage('Sonarqube analysis') {
           // Reference https://github.com/jatinngupta/Jenkins-SonarQube-Pipeline/blob/master/Jenkinsfile
               steps {
                   script {
                       scannerHome = tool 'sonar-scanner';
                   }
                    withCredentials([string(credentialsId: 'sonar', variable: 'sonarLogin')]) {
                       bat "${scannerHome}/bin/sonar-scanner -X -Dsonar.host.url=http://localhost:9000 -Dsonar.login=${sonarLogin} -Dsonar.projectName=${env.JOB_NAME} -Dsonar.projectVersion=${env.BUILD_NUMBER} -Dsonar.projectKey=${env.JOB_BASE_NAME} -Dsonar.sources=src/main/java -Dsonar.java.libraries=target/* -Dsonar.java.binaries=target/classes -Dsonar.language=java"
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
               stage('Deploy AWR ECR') {
                                steps{
                                  script {
                                    docker.withRegistry( '634057952844.dkr.ecr.us-east-1.amazonaws.com/petclinic20', 'ecr:us-east-1:aws_access' ) {
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
