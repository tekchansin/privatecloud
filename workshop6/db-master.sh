#!/bin/bash -v
echo root:centos | chpasswd


setenforce 0
cat << MARIA > /etc/yum.repos.d/mariadb.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.0/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
MARIA

yum install MariaDB-Galera-server MariaDB-client galera -y
yum install socat vim tmux  -y

systemctl start mysql
systemctl enable mysql

yum install firewalld -y
systemctl start firewalld
systemctl enable firewalld
for i in 3306 4444 4567 4568 22; do sudo firewall-cmd --permanent --add-port=$i/tcp; done;
firewall-cmd --reload

mysql -uroot -e "SET wsrep_on=OFF; GRANT ALL ON *.* TO wsrep_sst@'%' IDENTIFIED BY 'wspass';"
mysql -uroot -e "SET wsrep_on=OFF; DELETE FROM mysql.user WHERE user='';"
mysql -uroot -e "FLUSH PRIVILEGES"

#set wordpress database
echo "db_name:$db_name/db_user:$db_user/db_password:$db_password" > /root/db-master-vardb.txt
cat << EOF | mysql -u root
GRANT ALL PRIVILEGES ON *.* TO "sst"@"%" IDENTIFIED BY "Passw0rd";
CREATE DATABASE $db_name;
GRANT ALL PRIVILEGES ON $db_name.* TO "$db_user"@"%" IDENTIFIED BY "$db_password";
FLUSH PRIVILEGES;
EXIT
EOF

#stop mysql before start cluster
systemctl stop mysql
cat << WSREP > /etc/my.cnf.d/wsrep.cnf
[mariadb-10.0]
#mysqlconfig
bind-address=0.0.0.0
binlog_format=row
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
innodb_doublewrite=1

#wsrep config
wsrep_provider=/usr/lib64/galera/libgalera_smm.so
wsrep_cluster_name="OpenStack"
wsrep_sst_auth=wsrep_sst:wspass
wsrep_cluster_address="gcomm://"
wsrep_sst_method=rsync
wsrep_node_address="{NODE_ADDRESS}"
wsrep_node_name="{NODE_NAME}"
log-error = error.log
WSREP

export NODE_NAME=$HOSTNAME
export NODE_ADDRESS=$(ip addr show eth0 |  grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
#export NODE_ADDRESS=$host

sed -i "s/{NODE_ADDRESS}/$NODE_ADDRESS/" /etc/my.cnf.d/wsrep.cnf
sed -i "s/{NODE_NAME}/$NODE_NAME/" /etc/my.cnf.d/wsrep.cnf


/etc/init.d/mysql bootstrap
/etc/init.d/mysql start
sleep 5
sleep 5
