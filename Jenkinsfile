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
	
	}
	
	stages {
	    stage('Test Stage') {
			steps {
			    withMaven(maven : 'maven_3.6') {
					sh 'mvn test'
				}
			}
		}
	
	}
	
	stages {
	    stage('Compile Stage') {
			steps {
			    withMaven(maven : 'maven_3.6') {
					sh 'mvn deploy'
				}
			}
		}
	
	}

}
