pipeline {
    agent any

    tools {
        maven "MAVEN_HOME"
    }

    stages {
        stage("Build") {
            steps {
                bat  "mvn -version"
                bat  "mvn clean install"
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
