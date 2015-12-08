# -*- mode: ruby -*-
# vi: set ft=ruby :

VM_NAME = "cloud.example.com"
IP1 = "192.168.20.10"
IP2 = "192.168.30.10"
Vagrant.configure(2) do |config|
  config.vm.box = "centos71505"
  config.vm.hostname = "#{VM_NAME}"
  file_to_disk = './tmp/disk.vdi'

  config.vm.define :rdo do |rdo|
    rdo.vm.network :private_network, ip: "#{IP1}"
    rdo.vm.network  :private_network, ip: "#{IP2}"
    rdo.vm.provider :virtualbox do |vb|
      vb.name = "#{VM_NAME}"
      vb.gui = true
      vb.memory = "4096"
      vb.cpus = "2"
      vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
      vb.customize ['createhd', '--filename', file_to_disk, '--size', 10 * 1024]
      vb.customize ['storageattach', :id, '--storagectl', 'IDE Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
    end

  config.vm.provision "fix-no-tty", type: "shell" do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.bash_profile"
  end

 end

  config.vm.provision "shell", inline: <<-SHELL
  systemctl restart NetworkManager
  cat <<CONF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
CONF

  set -e
  set -x
  yum -y groupinstall "Development Tools"
  yum -y install git wget
  yum -y install python-devel libffi-devel openssl-devel  libyaml-devel
  yum update -y
  rpm -ivh http://buildlogs.centos.org/centos/7/cloud/x86_64/openstack-kilo/centos-release-openstack-kilo-1-2.el7.noarch.rpm
  cd /root
  curl -O https://raw.githubusercontent.com/thaiopen/privatecloud/master/answerfile.txt
  sleep 5
  git clone https://github.com/openstack/packstack.git
  sleep 5
  cd packstack
  python setup.py install
  python setup.py install_puppet_modules
  fdisk -u /dev/sdb <<EOF
n
p
1


t
8e
w
q
EOF

  partprobe /dev/sdb1
  pvcreate /dev/sdb1
  vgcreate cinder-volumes /dev/sdb1
  cd /root
  packstack --answer-file answerfile.txt
  cat <<BREX  > /etc/sysconfig/network-scripts/ifcfg-br-ex
DEVICE="br-ex"
BOOTPROTO="static"
IPADDR="192.168.20.10"
PREFIX=24
DNS1="8.8.8.8"
GATEWAY="192.168.20.1"
NM_CONTROLLED="no"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="yes"
IPV6INIT=no
ONBOOT="yes"
TYPE="OVSIntPort"
OVS_BRIDGE=br-ex
DEVICETYPE="ovs"
BREX
 
  IFACE=eth1
  read MAC </sys/class/net/$IFACE/address
  cat <<ETH1 > /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE="eth1"
ONBOOT="yes"
TYPE="OVSPort"
DEVICETYPE="ovs"
OVS_BRIDGE=br-ex
NM_CONTROLLED=no
IPV6INIT=no
HWADDR=$MAC
ETH1
  
  chkconfig network on
  service network restart
  systemctl stop NetworkManager
  systemctl disable NetworkManager

  sed -i "32i ServerAlias 192.168.20.10" /etc/httpd/conf.d/15-horizon_vhost.conf
  systemctl restart httpd
  SHELL
end
