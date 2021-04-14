#!groovy

pipeline {
    agent any

    tools {
        maven "MAVEN_HOME"
    }

    stages {
        stage("Build") {
            agent { label 'WindowsNode' }
            steps {
                sh "mvn -version"
                sh "mvn clean install"
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
