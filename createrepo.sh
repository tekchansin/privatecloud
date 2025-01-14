#!/bin/bash -v
# Create Repo Script server

echo root:centos | chpasswd
yum -y install epel-release
yum update -y
yum -y install httpd
yum -y install vim
yum -y install createrepo 
yum -y install mariadb mariadb-server  --downloadonly  --downloaddir=/var/www/html/repos/wordpress
yum -y install nodejs npm vim tmux git golang --downloadonly  --downloaddir=/var/www/html/repos/wordpress
yum -y install php php-gd php-mysql httpd wget --downloadonly  --downloaddir=/var/www/html/repos/wordpress
yum -y install keepalived haproxy --downloadonly  --downloaddir=/var/www/html/repos/wordpress
createrepo /var/www/html/repos/wordpress

systemctl start httpd
systemctl enable httpd