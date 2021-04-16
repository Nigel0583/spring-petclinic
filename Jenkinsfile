pipeline {
   environment {
      imagename = "nigel0582/pet_clinic_2"
      registryCredential = 'dockerhub'
      dockerImage = ''
      AWS_ACCESS_KEY_ID = credentials('jenkins-aws-secret-key-id')
      AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret-access-key')
      AWS_SESSION_TOKEN = credentials('jenkins_aws_session_token')
   }
   agent any

   tools {
      maven "MAVEN_HOME"
   }

   stages {
      stage("Build") {
         agent {
            label 'WindowsNode'
         }
         steps {
            bat "mvn -version"
            bat "mvn clean install"
         }
      }

      stage("Test") {
         steps {
            bat 'mvn test'
         }
         post {
            always {
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
      stage("Deploy") {
         steps {
            bat "mvn clean package"
         }
         post {
            success {
               archiveArtifacts 'target/*.jar'
            }
         }
      }

      stage('Building Docker Image') {
         steps {
            script {
               dockerImage = docker.build imagename
            }
         }
      }
      stage('Deploy Docker Docker') {
         steps {
            script {
               docker.withRegistry('', registryCredential) {
                  dockerImage.push("$BUILD_NUMBER")
                  dockerImage.push('latest')
               }
            }
         }
      }
      stage('Remove Unused Docker Docker') {
         steps {
            sh "docker rmi $imagename:$BUILD_NUMBER"
            sh "docker rmi $imagename:latest"
         }
      }

      stage('Publish to AWS S3') {
      //Reference https://coralogix.com/log-analytics-blog/ci-cd-tutorial-how-to-deploy-an-aws-jenkins-pipeline/
         steps {
            bat 'mvn package'
         }
         post {
            success {
               archiveArtifacts 'target/*.jar'
               bat 'aws configure set region us-east-1'
               bat 'aws s3 cp ./target/spring-petclinic-2.4.2.jar s3://elasticbeanstalk-us-east-1-634057952844/2021105Fw1-spring-petclinic-2.4.2.jar'
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
