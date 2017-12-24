#!/bin/sh

#provisions a 3-node cluster in openstack
# this script expects Openstack environment variables
# like OS_TENANT_ID, OS_PASSWORD to be set

source ./env.config

function delete_ssh_pubkey {
  openstack keypair delete ${OST_PRJ_NAME}
}

function delete_network {
 openstack subnet delete ${OST_SUBNET}
 openstack network delete ${OST_NET}
}

function delete_router {
  openstack router remove subnet ${OST_ROUTER} ${OST_SUBNET}
  openstack router delete ${OST_ROUTER}
}

function delete_docker {
   docker-machine rm ${OST_PRJ_NAME} -f 
}

function delete_sec_group {
  openstack security group delete ${OST_SEC_GROUP}
 }


function delete_all {
  delete_docker
  delete_router
  delete_network
  delete_sec_group
  delete_ssh_pubkey
}
