#!/bin/sh

#provisions a Docker-Server with Docker-Machine in openstack
# this script expects Openstack environment variables
# like OS_TENANT_ID, OS_PASSWORD to be set

# apt-get install openstack
# apt-get install curl

source env.config

MINER_SRV=MINER-${OST_PRJ_NAME}
echo ${MINER_SRV}

function start_srv {
    openstack server create --flavor ${OST_FLAVOR} \
              --key-name ${OST_PRJ_NAME} \
              --image ${OST_IMAGE} \
              --security-group ${OST_SEC_GROUP} \
              --user-data user_data/miner.txt \
              --min 2 \
              --max 2 \
              ${MINER_SRV}
}

