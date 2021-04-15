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
           stage('SonarQube') {
                 def sonarqubeScannerHome = tool name: 'sonar-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                 withCredentials([string(credentialsId: 'sonar', variable: 'sonarLogin')]) {
                   sh "${sonarqubeScannerHome}/bin/sonar-scanner -X -Dsonar.host.url=http://localhost:9000 -Dsonar.login=${sonarLogin} -Dsonar.projectName=${env.JOB_NAME} -Dsonar.projectVersion=${env.BUILD_NUMBER} -Dsonar.projectKey=${env.JOB_BASE_NAME} -Dsonar.sources=src/main/java -Dsonar.java.libraries=target/* -Dsonar.java.binaries=target/classes -Dsonar.language=java"
                 }
               bat "sleep 40"
               env.WORKSPACE = pwd()
               def file = readFile "${env.WORKSPACE}/.scannerwork/report-task.txt"
               echo file.split("\n")[5]

               def resp = httpRequest file.split("\n")[5].split("l=")[1]

               ceTask = readJSON text: resp.content
               echo ceTask.toString()

               def response2 = httpRequest url : 'http://localhost:9000' + "/api/qualitygates/project_status?analysisId=" + ceTask["task"]["analysisId"]
               def qualitygate =  readJSON text: response2.content
               echo qualitygate.toString()
               if ("ERROR".equals(qualitygate["projectStatus"]["status"])) {
                   echo "Build Failed"
               }
                  else {
                   echo "Build Passed"
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
