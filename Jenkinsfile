pipeline {
    environment {
            JAVA_TOOL_OPTIONS = "-Duser.home=/var/maven"
        }
        agent {
            docker {
                image "maven:3.6.0-jdk-13"
                label "docker"
                args "-v /tmp/maven:/var/maven/.m2 -e MAVEN_CONFIG=/var/maven/.m2"
            }
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
    }
    post {
        always {
            cleanWs()
        }
    }
}
