#!/bin/sh

#provisions a Docker-Server with Docker-Machine in openstack
# this script expects Openstack environment variables
# like OS_TENANT_ID, OS_PASSWORD to be set

# apt-get install openstack
# apt-get install curl

source ./env.config

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
  openstack security group rule create --proto icmp ${OST_SEC_GROUP} 			#icmp ping
  openstack security group rule create --protocol tcp --dst-port 2376 ${OST_SEC_GROUP} 	#  Docker-Machine
  openstack security group rule create --proto tcp --dst-port 22 ${OST_SEC_GROUP} 	# SSH
}

function _create_docker {
   docker-machine -D create \
         --engine-storage-driver overlay \
         --driver openstack \
         --openstack-image-id ${OST_IMAGE} \
         --openstack-flavor-id 2 \
         --openstack-floatingip-pool public \
         --openstack-net-name ${OST_NET} \
         --openstack-sec-groups ${OST_SEC_GROUP} \
         --openstack-ssh-user ubuntu \
         --openstack-keypair-name ${OST_PRJ_NAME} \
         --openstack-private-key-file ${SSH_KEY} \
         ${OST_PRJ_NAME}
}

function create_docker {
   docker-machine status ${OST_PRJ_NAME} ||  _create_docker	
}

function get_info {
   docker-machine ls
   openstack server list
   openstack network list
   openstack subnet list
   openstack router list
   openstack security group list
   openstack security group rule list
}

function create_ost {
  create_ssh_pubkey
  create_network
  create_router 
  create_docker
  create_sec_group
}


