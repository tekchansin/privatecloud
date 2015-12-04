#!/bin/bash -v
# Create Repo Script server

echo root:centos | chpasswd

yum update -y
yum -y install httpd
yum -y install vim
yum -y install createrepo 
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
yum -y --enablerepo=remi install wordpress --downloadonly   --downloaddir=/var/www/html/repos/wordpress
yum -y install mariadb mariadb-server  --downloadonly  --downloaddir=/var/www/html/repos/wordpress
createrepo /var/www/html/repos/wordpress
systemctl start httpd