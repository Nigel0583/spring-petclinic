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
                    vat "mvn clean install"
                }
            }
        }

    post {
        always {
            cleanWs()
        }
    }
}
