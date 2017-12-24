#!/bin/sh

#provisions a 3-node cluster in openstack
# this script expects Openstack environment variables
# like OS_TENANT_ID, OS_PASSWORD to be set

#requires
# pip install python-novaclient
# pip install python-neutronclient

source env.config

function delete_ssh_pubkey {
  nova keypair-delete ${KEY_NAME}
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
  nova secgroup-delete-rule ${SECURITY_GROUP} icmp -1 -1 0.0.0.0/0    #icmp ping
  nova secgroup-delete-rule ${SECURITY_GROUP} tcp 22 22 0.0.0.0/0     #ssh
  nova secgroup-delete-rule ${SECURITY_GROUP} tcp 5050 5050 0.0.0.0/0 #mesos-leader
  nova secgroup-delete-rule ${SECURITY_GROUP} tcp 5051 5051 0.0.0.0/0 #mesos-follower
  nova secgroup-delete-rule ${SECURITY_GROUP} tcp 8080 8080 0.0.0.0/0 #marathon
  nova secgroup-delete-rule ${SECURITY_GROUP} tcp 8500 8500 0.0.0.0/0 #consul
  nova secgroup-delete-rule ${SECURITY_GROUP} tcp 9090 9090 0.0.0.0/0 #mesos libprocess
}


function delete_all {
  delete_docker
  delete_router
  delete_network
  delete_sec_group
  delete_ssh_pubkey
}
