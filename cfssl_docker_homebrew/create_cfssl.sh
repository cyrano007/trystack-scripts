#!/bin/bash

source ./../env.config

DOCKERHOST_DIR="/etc/cfssl"
DOCKER_DIR=${DOCKERHOST_DIR}
DOCKERIMAGE="cyrano007/cfssl"
CONFIG_FILES="config.json ca.json config_intermediate.json intermediate_ca.json"

function _prov_port {
  openstack security group rule create --proto tcp --dst-port 8888 ${OST_SEC_GROUP}
}

function _prov_ca {
  docker-machine ssh ${OST_PRJ_NAME} sudo rm -rf ${DOCKER_DIR}
  docker-machine ssh ${OST_PRJ_NAME} sudo mkdir ${DOCKER_DIR}
  for FILE in ${CONFIG_FILES}
  do
    docker-machine scp ./${FILE} ${OST_PRJ_NAME}:/tmp/.
  done
  docker-machine ssh ${OST_PRJ_NAME} sudo mv /tmp/*.json ${DOCKER_DIR}
  docker-machine ssh ${OST_PRJ_NAME} sudo ls -rtl ${DOCKER_DIR}
}

function create_ca {
  eval $(docker-machine env ${OST_PRJ_NAME})
  docker build -t ${DOCKERIMAGE} .
  docker run --rm -v ${DOCKERHOST_DIR}:${DOCKER_DIR} ${DOCKERIMAGE} genkey -initca ca.json | docker run --rm -i -v ${DOCKERHOST_DIR}:${DOCKER_DIR} --entrypoint cfssljson ${DOCKERIMAGE} -bare ca
  docker run -d -v ${DOCKERHOST_DIR}:${DOCKER_DIR} --name cfssl ${DOCKERIMAGE} serve -address=0.0.0.0 -config=config.json
  #docker run --rm -v /etc/cfssl:/etc/cfssl cyrano007/cfssl genkey -initca intermediate_ca.json | docker run --rm -i -v /etc/cfssl:/etc/cfssl --entrypoint cfssljson cyrano007/cfssl -bare intermediate_ca
  #docker run --rm -v /etc/cfssl:/etc/cfssl cyrano007/cfssl sign -ca ca.pem -ca-key ca-key.pem -config config_intermediate.json intermediate_ca.csr | docker run --rm -i -v /etc/cfssl:/etc/cfssl --entrypoint cfssljson cyrano007/cfssl -bare intermediate_ca
  #docker run -d -v /etc/cfssl:/etc/cfssl --name intermediate_ca cyrano007/cfssl serve -address=0.0.0.0 -config=config_intermdiate.json
}

function prov_host_machine {
  echo "Erweitere openstack security group rule create --proto tcp --dst-port 8888 ${OST_SEC_GROUP}"
  _prov_port
  echo "Kopiere CONFIG_FILES: ${CONFIG_FILES}"
  _prov_ca
  echo "Baue und erstelle Dockerapp"
  create_ca
}
