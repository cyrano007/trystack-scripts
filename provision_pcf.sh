#!/bin/sh

#provisions a Docker-Server with Docker-Machine in openstack
# this script expects Openstack environment variables
# like OS_TENANT_ID, OS_PASSWORD to be set

source env.config

function pre_pcf_concourse_srv {
   docker-machine ssh ${OST_PRJ_NAME} "mkdir -p keys/web keys/worker"
   docker-machine ssh ${OST_PRJ_NAME} "ssh-keygen -t rsa -f ./keys/web/tsa_host_key -N ''"
   docker-machine ssh ${OST_PRJ_NAME} "ssh-keygen -t rsa -f ./keys/web/session_signing_key -N ''"
   docker-machine ssh ${OST_PRJ_NAME} "ssh-keygen -t rsa -f ./keys/worker/worker_key -N ''"
   docker-machine ssh ${OST_PRJ_NAME} "cp ./keys/worker/worker_key.pub ./keys/web/authorized_worker_keys"
   docker-machine ssh ${OST_PRJ_NAME} "cp ./keys/web/tsa_host_key.pub ./keys/worker"
}

function create_concourse_docker_srv {
 echo "Hallo"
}
