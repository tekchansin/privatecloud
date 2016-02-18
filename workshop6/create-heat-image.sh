#!/bin/bash

yum install qemu-img
yum install python-pip git

git clone https://git.openstack.org/openstack/diskimage-builder.git
git clone https://git.openstack.org/openstack/tripleo-image-elements.git
git clone https://git.openstack.org/openstack/heat-templates.git
git clone https://git.openstack.org/openstack/dib-utils.git
export PATH="${PWD}/dib-utils/bin:$PATH"
						
export ELEMENTS_PATH=tripleo-image-elements/elements:heat-templates/hot/software-config/elements
export BASE_ELEMENTS="centos7 selinux-permissive"
export AGENT_ELEMENTS="os-collect-config os-refresh-config os-apply-config"
export DEPLOYMENT_BASE_ELEMENTS="heat-config heat-config-script"
export IMAGE_NAME=software-deployment-image
diskimage-builder/bin/disk-image-create vm $BASE_ELEMENTS $AGENT_ELEMENTS $DEPLOYMENT_BASE_ELEMENTS $DEPLOYMENT_TOOL -o $IMAGE_NAME.qcow2
