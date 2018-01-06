#!/bin/sh

#provisions a Docker-Server with Docker-Machine in openstack
# this script expects Openstack environment variables
# like OS_TENANT_ID, OS_PASSWORD to be set

# apt-get install openstack
# apt-get install curl

source env.config

OST_SRV=SRV-${OST_PRJ_NAME}

function create_ssh_pubkey {
  openstack keypair create --public-key ${SSH_KEY}.pub ${OST_PRJ_NAME}
}

function _create_network {
  openstack network create ${OST_NET}
  openstack subnet create ${OST_SUBNET} --network ${OST_NET} --subnet-range 192.168.1.0/24 --dns-nameserver 8.8.8.8
}

function create_network {
  openstack network show ${OST_NET} || _create_network
}

function _create_router {
  openstack router create ${OST_ROUTER}
  openstack router set ${OST_ROUTER} --external-gateway public
  openstack router add subnet ${OST_ROUTER} ${OST_SUBNET} 
}

function create_router {
  openstack router show ${OST_ROUTER} || _create_router
}

function create_sec_group {
  openstack security group create ${OST_SEC_GROUP}
  openstack security group rule create --proto icmp ${OST_SEC_GROUP} 			#  icmp ping
  openstack security group rule create --protocol tcp --dst-port 2376 ${OST_SEC_GROUP} 	#  Docker-Machine
  openstack security group rule create --proto tcp --dst-port 22 ${OST_SEC_GROUP} 	#  SSH
}

function start_srv {
    openstack server create --flavor ${OST_FLAVOR} \
              --key-name ${OST_PRJ_NAME} \
              --image ${OST_IMAGE} \
              --security-group ${OST_SEC_GROUP} \
              --user-data user_data/data.txt \
              ${OST_SRV}
}


function get_info {
   openstack server list
   openstack network list
   openstack subnet list
   openstack router list
   openstack security group list
   openstack security group rule list
   openstack keypair list
}

function create_ost {
  create_ssh_pubkey
  create_sec_group
  create_network
  create_router 
  get_info
}

