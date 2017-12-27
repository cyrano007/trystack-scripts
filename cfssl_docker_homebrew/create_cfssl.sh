#!/bin/bash

source ./../env.config

function prov_trystack {
  openstack security group rule create --proto tcp --dst-port 8888 ${OST_SEC_GROUP} 	
}

function prov_host_machine {
  docker-machine ssh ${OST_PRJ_NAME} sudo rm -rf /etc/cfssl
  docker-machine ssh ${OST_PRJ_NAME} sudo mkdir /etc/cfssl
  docker-machine scp ./config.json ${OST_PRJ_NAME}:/tmp/.
  docker-machine scp ./ca.json ${OST_PRJ_NAME}:/tmp/.
  docker-machine ssh ${OST_PRJ_NAME} sudo mv /tmp/*.json /etc/cfssl
  docker-machine ssh ${OST_PRJ_NAME} sudo ls -rtl /etc/cfssl
}

function create_cfssl_srv {
  eval $(docker-machine env ${OST_PRJ_NAME})
  docker build -t cyrano007/cfssl .
  docker run --rm -v /etc/cfssl:/etc/cfssl cyrano007/cfssl genkey -initca ca.json | \
  docker run --rm -i -v /etc/cfssl:/etc/cfssl --entrypoint cfssljson cyrano007/cfssl -bare ca
  docker run -d -v /etc/cfssl:/etc/cfssl --name cfssl cyrano007/cfssl serve -address=0.0.0.0 -config=config.json
}
