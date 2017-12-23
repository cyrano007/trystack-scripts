#!/bin/sh

#provisions a 3-node cluster in openstack
# this script expects Openstack environment variables
# like OS_TENANT_ID, OS_PASSWORD to be set

# apt-get install openstack

FLAVOR=3   #m1.medium (3.75GB)
IMAGE=2e4c08a9-0ecd-4541-8a45-838479a88552 # CentOS 7 x86_64


##### Openstack Network
SSH_KEY=~/.ssh/ost
SECURITY_GROUP=default
OST_PRJ_NAME="Docker-SRV"
OST_NET="NET-${OST_PRJ_NAME}"
OST_SUBNET="SUBNET-${OST_PRJ_NAME}"
OST_ROUTER="RTR-${OST_PRJ_NAME}"

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

function delete_network {
 openstack subnet delete ${OST_SUBNET}
 openstack network delete ${OST_NET}
}

function _create_router {
  openstack router create ${OST_ROUTER}
  openstack router set ${OST_ROUTER} --external-gateway public
  openstack router add subnet ${OST_ROUTER} ${OST_SUBNET} 
}

function create_router {
  openstack router show ${OST_ROUTER} || _create_router
}
function delete_router {
  openstack router remove subnet ${OST_ROUTER} ${OST_SUBNET}
  sleep 5
  openstack router delete ${OST_ROUTER}
  sleep 5
}

function default_sec_group {
  openstack security group rule create --protocol tcp --dst-port 2376:2376 --ingress --remote-ip 0.0.0.0/0 ${SECURITY_GROUP}
}

function create_docker {
   docker-machine -D create \
         --engine-storage-driver overlay \
         --driver openstack \
         --openstack-image-id 76f5f4aa-a78f-4703-b738-cab967957431 \
         --openstack-flavor-id 2 \
         --openstack-floatingip-pool public \
         --openstack-net-name ${OST_NET} \
         --openstack-sec-groups default \
         --openstack-ssh-user ubuntu \
         --openstack-keypair-name ${OST_PRJ_NAME} \
         --openstack-private-key-file ${SSH_KEY} \
         ${OST_PRJ_NAME}

}
function delete_docker {
   docker-machine rm ${OST_PRJ_NAME} -f 
}

function create_ost {
  create_ssh_pubkey
  create_network
  create_router 
  create_docker
  # default_sec_group
}

function delete_ost {
  delete_docker
  delete_router
  delete_network
}
