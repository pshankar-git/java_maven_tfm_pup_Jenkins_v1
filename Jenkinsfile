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

        stage ('Tomcat SSH key Setup') {
            steps {
                sh 'tomcat_setup_dir=/opt/tomcat_jenkins_setup && mkdir -p ${tomcat_setup_dir}'
                script {
                    def tomcat_key_file = fileExists '/opt/tomcat_jenkins_setup/tomcat_ec2_key'
                    if (tomcat_key_file) {
                        sh 'echo Tomcat ssh key already present'
                    } else {
                        sh 'ssh-keygen -f ${tomcat_setup_dir}/tomcat_ec2_key -N ""'
                        sh 'echo Tomcat Key generated successfully'
                    }

                }
            }
        }

        stage ('Terraform Setup') {
            steps {
                script {
                    def tfHome = tool name: 'Terraform_0.12.6', type: 'org.jenkinsci.plugins.terraform.TerraformInstallation'

                }
            sh 'terraform --version'

            }
        }
        stage ('Terraform Init and Plan') {
            steps {
                sh 'terraform init $WORKSPACE'
                sh 'terraform plan'
            }
        }

        stage ('Terraform Apply') {
            steps {
                sh 'terraform apply --auto-approve'
            }
        }

        stage ('Setting up Host variables') {
            steps {
                sh """
                    export tc_server_pub_dns=`terraform output -json tomcat_public_dns | cut -d '"' -f2`
                    export tc_server_pri_dns=`terraform output -json tomcat_private_dns | cut -d '"' -f2`
                    export tc_server_pub_ip=`terraform output -json tomcat_public_ip | cut -d '"' -f2`
                    export tc_server_pri_ip=`terraform output -json tomcat_private_ip | cut -d '"' -f2`
                    export pupmaster_pri_dns=`sed -n '1p' < /opt/pup_setup_tf/ec2_private_dns.txt`
                    export pupmaster_pri_ip=`sed -n '1p' < /opt/pup_setup_tf/ec2_private_ip.txt`                    
                """
            }
        }    
        
        stage ('Setting up puppet node on Tomcat server') {
            steps {
                sh """
                    ssh -i /opt/tomcat_jenkins_setup/tomcat_ec2_key -tt ubuntu@$tc_server_pri_dns -oStrictHostKeyChecking=no <<EOF
                    sudo su -
                    hostname tomcatpuppetagent.ec2.internal
                    echo tomcatpuppetagent.ec2.internal > /etc/hostname
                    apt-get update -y
                    echo $pupmaster_pri_ip puppetmaster.ec2.internal ${pupmaster_pri_dns} >> /etc/hosts
                    echo ${tc_server_pri_ip} tomcatpuppetagent.ec2.internal ${tc_server_pri_dns} >> /etc/hosts
                    wget https://apt.puppetlabs.com/puppet-release-bionic.deb
                    dpkg -i puppet-release-bionic.deb
                    apt-get install puppet -y
                    mv /etc/puppet/puppet.conf /etc/puppet/puppet.conf.orig
                    echo [main] > /etc/puppet/puppet.conf
                    echo ssldir = /var/lib/puppet/ssl >> /etc/puppet/puppet.conf
                    echo certname = tomcatpuppetagent.ec2.internal >> /etc/puppet/puppet.conf
                    echo server = puppetmaster.ec2.internal >> /etc/puppet/puppet.conf
                    systemctl restart puppet
                    systemctl enable puppet
                    exit
                    exit
                    EOF
                    """.stripIndent()
            }
        }

        stage ('Puppet Master') {
            steps {
                sshagent(['ubuntu']) {
                    echo 'Deploying....'
                    sh """
                    ssh -tt ubuntu@ec2-54-167-14-15.compute-1.amazonaws.com -oStrictHostKeyChecking=no <<EOF
                    sudo su -
                    echo ${tc_server_pri_ip} tomcatpuppetagent.ec2.internal ${tc_server_pri_dns} >> /etc/hosts
                    echo "## SIGNING PUPPET AGENT CERTIFICATE REQUEST ##"
                    puppet cert list
                    puppet cert sign tomcatpuppetagent.ec2.internal
                    exit
                    exit

                    /* cd /etc/puppet/code/environments/test/modules
                    puppet module install puppetlabs-java
                    sleep 15
                    ls -ltr
                    exit
                    exit */
                    EOF
                    """.stripIndent()
                }
            }

        }

        stage ('Testing Tomcat Agent') {
            steps {
                sshagent(['ubuntu']) {
                    echo 'Testing Tomcat puppet Agent status....'
                    sh """
                    ssh -i /opt/tomcat_jenkins_setup/tomcat_ec2_key -tt ubuntu@$tc_server -oStrictHostKeyChecking=no <<EOF
                    sudo su -
                    puppet agent -t
                    sleep 15
                    exit
                    exit
                    EOF
                    """.stripIndent()
                }
            }


        }
    }
}


