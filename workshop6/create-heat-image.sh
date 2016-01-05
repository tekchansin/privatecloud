#!/bin/bash
yum install epel-release
yum install qemu-img
yum install python-pip git
pip install git+git://git.openstack.org/openstack/dib-utils.git
export ELEMENTS_PATH=tripleo-image-elements/elements:heat-templates/hot/software-config/elements
export BASE_ELEMENTS="centos7 selinux-permissive"
export AGENT_ELEMENTS="os-collect-config os-refresh-config os-apply-config"
export DEPLOYMENT_BASE_ELEMENTS="heat-config heat-config-script"
export DEPLOYMENT_TOOL=""
export IMAGE_NAME=software-deployment-image
diskimage-builder/bin/disk-image-create vm $BASE_ELEMENTS $AGENT_ELEMENTS $DEPLOYMENT_BASE_ELEMENTS $DEPLOYMENT_TOOL -o $IMAGE_NAME.qcow2
glance image-create --name CentOS-7-x86_64-heat --disk-format qcow2 --container-format bare --file software-deployment-image.qcow2

