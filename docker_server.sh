#!/bin/sh

# provisions a Docker-Server with Docker-Machine in openstack
# this script expects Openstack environment variables
# like OS_TENANT_ID, OS_PASSWORD to be set

# apt-get install openstack
# apt-get install curl

source env.config

DOCKER_SRV=DSRV-${OST_PRJ_NAME}


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
         ${DOCKER_SRV}
}

function create_docker {
   docker-machine status ${DOCKER_SRV} ||  _create_docker
   docker-machine ls
}


function create_ost {
  create_docker
}
