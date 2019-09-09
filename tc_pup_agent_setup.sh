#!/bin/bash
#
# This script does the following
#
#    * Create AWS resources like EC2 instance, Security Group and a Key pair for Tomcat App Server
#    * Install Puppet Agent package on the newly create Tomcat ec2 instance
#    * Configure /etc/puppet/puppet.conf for thr Tomcat Puppet Agent
#    * Generate certificate signing request to Puppet Master
#    * Puppet Master to sign the CSR generated and add Tomcat server as a puppet agent

# FETCHING TOMCAT AND PUPPET MASTER SERVER DNS and IP's

printf "\nFETCHING TOMCAT AND PUPPET MASTER SERVER DNS and IP's\n"
TC_SERVER_PRI_DNS=`sed -n '1p' < tc_pri_dns.txt`
echo $TC_SERVER_PRI_DNS
TC_SERVER_PRI_IP=`sed -n '1p' < tc_pri_ip.txt`
echo $TC_SERVER_PRI_IP
PUPMASTER_PRI_IP=`sed -n '1p' < pup_master_pri_ip.txt`
echo $PUPMASTER_PRI_IP
PUPMASTER_PRI_DNS=`sed -n '1p' < pup_master_pri_dns.txt`
echo $PUPMASTER_PRI_DNS

printf "\nSSH TO TOMCAT EC2 INSTANCE AND INSTALL PUPPET AGENT\n"
sleep 20
ssh -t ubuntu@$TC_SERVER_PRI_DNS -i "tomcat_ec2_key" -oStrictHostKeyChecking=no "/usr/bin/sudo bash -c 'hostname tomcatpuppetagent.ec2.internal; \
echo tomcatpuppetagent.ec2.internal > /etc/hostname; \
echo $PUPMASTER_PRI_IP puppetmaster.ec2.internal ${PUPMASTER_PRI_DNS} >> /etc/hosts; \
echo ${TC_SERVER_PRI_IP} tomcatpuppetagent.ec2.internal ${TC_SERVER_PRI_DNS} >> /etc/hosts; \
wget https://apt.puppetlabs.com/puppet-release-bionic.deb; \
dpkg -i puppet-release-bionic.deb; \
apt-get update -y; \
apt-get install puppet -y; \
exit;'"

printf "\nCONFIGURING PUPPET AGENT ON TOMCAT EC2 INSTANCE\n"
ssh -t ubuntu@$TC_SERVER_PRI_DNS -i "tomcat_ec2_key" -oStrictHostKeyChecking=no "/usr/bin/sudo bash -c 'mv /etc/puppet/puppet.conf /etc/puppet/puppet.conf.orig; \
echo [main] > /etc/puppet/puppet.conf; \
echo ssldir = /var/lib/puppet/ssl >> /etc/puppet/puppet.conf; \
echo certname = tomcatpuppetagent.ec2.internal >> /etc/puppet/puppet.conf; \
echo server = puppetmaster.ec2.internal >> /etc/puppet/puppet.conf; \
echo environment = production >> /etc/puppet/puppet.conf; \
export PATH=$PATH:/opt/puppetlabs/puppet/bin; \
systemctl restart puppet; \
systemctl enable puppet; \
exit;'"

printf "\nSIGNING PUPPET CERTS FROM PUPPET MASTER FOR NEWLY CREATED TOMCAT PUPPET AGENT\n"
ssh -i /opt/pup_setup_tf/puppet_ec2_key -t ubuntu@$PUPMASTER_PRI_IP -oStrictHostKeyChecking=no "/usr/bin/sudo bash -c 'echo ${TC_SERVER_PRI_IP} tomcatpuppetagent.ec2.internal ${TC_SERVER_PRI_DNS} >> /etc/hosts; \
puppet cert list; \
puppet cert sign tomcatpuppetagent.ec2.internal; \
exit;'"

printf "\nTEST TOMCAT PUPPET AGENT CONNECTION TO PUPPET MASTER AND APPLY CATALOG\n"
ssh -i tomcat_ec2_key -t ubuntu@$TC_SERVER_PRI_DNS -oStrictHostKeyChecking=no "/usr/bin/sudo bash -c 'puppet agent --test; \
exit;'"

