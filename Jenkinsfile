pipeline {
    agent any

    stages {

        stage('SCM Checkout') {
            steps {
                git credentialsId: '8e237d54-cc07-4aad-a3fe-51855a4d84c1', url: 'https://github.com/pramodk05/java_maven_jenkins.git'
            }
        }

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

        
        stage('Create the Build artifacts Stage (Package)') {
            steps {
                withMaven(maven : 'maven_3.6') {
                    sh 'mvn package'
                }
            }
        }

        stage('Deployment Stage - Tomcat Container') {
            steps {
                deploy adapters: [tomcat8(credentialsId: 'f5c26087-bdee-4306-967a-6ae8eeec19d0', path: '', url: 'http://3.83.255.30:8080')], contextPath: 'mvn-hello-world', war: 'target/*.war'
            }
        }
        
    }
}
