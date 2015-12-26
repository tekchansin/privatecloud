#!/bin/bash -v
# Create Repo Script server
cat << REPO > /etc/yum.repos.d/mariadb.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.0/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=0
enabled=1
REPO

echo root:centos | chpasswd
yum -y install epel-release
yum update -y
yum -y install httpd
yum -y install vim
yum -y install createrepo 
yum -y install mariadb mariadb-server  --downloadonly  --downloaddir=/var/www/html/repos/wordpress
yum -y install nodejs npm vim tmux git golang --downloadonly  --downloaddir=/var/www/html/repos/wordpress
yum -y install php php-gd php-mysql httpd wget --downloadonly  --downloaddir=/var/www/html/repos/wordpress
yum -y install MariaDB-Galera-server --downloadonly  --downloaddir=/var/www/html/repos/wordpress
yum -y install keepalived haproxy --downloadonly  --downloaddir=/var/www/html/repos/wordpress
createrepo /var/www/html/repos/wordpress

systemctl start httpd
systemctl enable httpd