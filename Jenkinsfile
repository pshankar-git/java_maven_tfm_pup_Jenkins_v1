pipeline {
    agent any

    stages {

        stage('Compile Stage') {
            steps {
                withMaven(maven : 'maven_3.6') {
                    sh 'mvn clean compile'
                }
            }
        }

        
        stage('Test Stage') {
            steps {
                withMaven(maven : 'maven_3.6') {
                    sh 'mvn test'
                }
            }
        }

        
        stage('Deploy Stage') {
            steps {
                withMaven(maven : 'maven_3.6') {
                    sh 'mvn deploy'
                }
            }
        }
    }
}
