tc_server_pri_dns=`sed -n '1p' < tc_pri_dns.txt`
echo $tc_server_pri_dns
tc_server_pri_ip=`sed -n '1p' < tc_pri_ip.txt`
echo $tc_server_pri_ip
pupmaster_pri_ip=`sed -n '1p' < pup_master_pri_ip.txt`
echo $pupmaster_pri_ip
pupmaster_pri_dns=`sed -n '1p' < pup_master_pri_dns.txt`
echo $pupmaster_pri_dns
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
