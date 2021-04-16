pipeline {
    environment {
        imagename = "nigel0582/pet_clinic_2"
        registryCredential = 'dockerhub'
        dockerImage = ''
        AWS_ACCESS_KEY_ID = credentials('jenkins-aws-secret-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret-access-key')
        AWS_SESSION_TOKEN = credentials('jenkins_aws_session_token')
        ARTIFACT_NAME = '2021105Fw1-spring-petclinic-2.4.2.jar'
        AWS_S3_BUCKET = 'elasticbeanstalk-us-east-1-634057952844'
        AWS_EB_APP_NAME = 'petclinic'
        AWS_EB_ENVIRONMENT = 'Petclinic-env'
        AWS_EB_APP_VERSION = "${BUILD_ID}"
    }
    agent {
        label 'WindowsNode'
    }

    tools {
        maven "MAVEN_HOME"
    }

    stages {
        stage("Build") {
            steps {
                bat "mvn -version"
                bat "mvn clean install"
            }
        }

        stage("Junit Testing") {
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
                bat "sleep 40"
                env.WORKSPACE = pwd()
                def file = readFile "${env.WORKSPACE}/.scannerwork/report-task.txt"
                echo file.split("\n")[5]

                def resp = httpRequest file.split("\n")[5].split("l=")[1]

                ceTask = readJSON text: resp.content
                echo ceTask.toString()

                def response2 = httpRequest url: 'http://localhost:9000' + "/api/qualitygates/project_status?analysisId=" + ceTask["task"]["analysisId"]
                def qualitygate = readJSON text: response2.content
                echo qualitygate.toString()
                if ("ERROR".equals(qualitygate["projectStatus"]["status"])) {
                    echo "Build Failed"
                } else {
                    echo "Build Passed"
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
            stage('Deploy Docker Image') {
                steps {
                    script {
                        docker.withRegistry('', registryCredential) {
                            dockerImage.push("$BUILD_NUMBER")
                            dockerImage.push('latest')
                        }
                    }
                }
            }
            stage('Remove Unused Docker Image') {
                steps {
                    sh "docker rmi $imagename:$BUILD_NUMBER"
                    sh "docker rmi $imagename:latest"
                }
            }

            stage('Publish to AWS S3 and AWS Elastic Beanstalk') {
                //Reference https://coralogix.com/log-analytics-blog/ci-cd-tutorial-how-to-deploy-an-aws-jenkins-pipeline/
                steps {
                    bat "mvn clean package"
                }
                post {
                    success {
                        archiveArtifacts 'target/*.jar'
                        sh 'aws configure set region us-east-1'
                        sh 'aws s3 cp ./target/spring-petclinic-2.4.2.jar s3://$AWS_S3_BUCKET/$ARTIFACT_NAME'
                        sh 'aws elasticbeanstalk create-application-version --application-name $AWS_EB_APP_NAME --version-label $AWS_EB_APP_VERSION --source-bundle S3Bucket=$AWS_S3_BUCKET,S3Key=$ARTIFACT_NAME'
                        sh 'aws elasticbeanstalk update-environment --application-name $AWS_EB_APP_NAME --environment-name $AWS_EB_ENVIRONMENT --version-label $AWS_EB_APP_VERSION'
                    }
                }
            }
    }
        post {
            always {
                cleanWs()

				emailext body: "${DEFAULT_CONTENT}",
                recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']],
                subject: "${DEFAULT_SUBJECT}"
            }
        }
    
