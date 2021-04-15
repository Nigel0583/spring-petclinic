@Library('github.com/releaseworks/jenkinslib') _

def awsCredentials = [[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws_access']]

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
/*
node {
   // ...
   withAwsCli(
         credentialsId: 'aws_access',
         defaultRegion: 'us-east-1']) {

        bat '''
           # COPY CREATED WAR FILE TO AWS S3
           aws s3 cp ./target/spring-petclinic-2.4.2.jar s3://elasticbeanstalk-us-east-1-634057952844/2021105Fw1-spring-petclinic-2.4.2.jar
           # CREATE A NEW BEANSTALK APPLICATION VERSION BASED ON THE WAR FILE LOCATED ON S3
           aws elasticbeanstalk create-application-version \
              --application-name petclinic \
              --version-label "jenkins$BUILD_DISPLAY_NAME" \
              --description "Created by $BUILD_TAG" \
              --source-bundle=S3Bucket=cloudbees-aws-demo,S3Key=petclinic.war
           # UPDATE THE BEANSTALK ENVIRONMENT TO CREATE THE NEW APPLICATION VERSION
           aws elasticbeanstalk update-environment \
              --environment-name=petclinic-qa-env \
              --version-label "jenkins$BUILD_DISPLAY_NAME"
        '''
   }
}
*/
              stage('Publish to AWS S3') {
                steps{
                                  script {
                                    withAwsCli(
                                            credentialsId: 'aws_access',
                                            defaultRegion: 'us-east-1']) {

                                           bat '''
                                              # COPY CREATED WAR FILE TO AWS S3
                                              aws s3 cp ./target/spring-petclinic-2.4.2.jar s3://elasticbeanstalk-us-east-1-634057952844/2021105Fw1-spring-petclinic-2.4.2.jar
                                              # CREATE A NEW BEANSTALK APPLICATION VERSION BASED ON THE WAR FILE LOCATED ON S3
                                              aws elasticbeanstalk create-application-version \
                                                 --application-name petclinic \
                                                 --version-label "jenkins$BUILD_DISPLAY_NAME" \
                                                 --description "Created by $BUILD_TAG" \
                                                 --source-bundle=S3Bucket=elasticbeanstalk-us-east-1-634057952844/2021105Fw1
                                              # UPDATE THE BEANSTALK ENVIRONMENT TO CREATE THE NEW APPLICATION VERSION
                                              aws elasticbeanstalk update-environment \
                                                 --environment-name=petclinic-qa-env \
                                                 --version-label "jenkins$BUILD_DISPLAY_NAME"
                                           '''
                                    }
                }                 }

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
