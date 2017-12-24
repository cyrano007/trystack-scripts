Overview:
========
Functions to provision a simple docker-server with docker-machine in trystack

- Sets up networks
- Configures ssh key
- creates a router and attaches it the external network
- boot and install docker-server with docker-machine


Requirements
============


- Account on http://trystack.org
- Install Openstack Clients:

		sudo apt-get install openstack
		sudo apt-get install curl
		$ curl -L https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && chmod +x /tmp/docker-machine && sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
		

- Have openstack environment environment varibles similar to this:

		export OS_AUTH_URL=http://8.21.28.222:5000/v2.0
		export OS_TENANT_ID=<sha_string>
		export OS_TENANT_NAME="facebookXXXXX"
		export OS_USERNAME="facebookXXXXX"
		export OS_PASSWORD=<trystack api key>
		export OS_REGION_NAME="RegionOne"


Note: the `OS_AUTH_URL` can be obtained from the Instances->Access & Security->API Access in the Openstack console. 


Running:
========

  	source provision.sh
  
To run everything:

  	create_ost
  	
  	
Each function can be run separately. 

Functions:
=========

	create_ssh_pubkey: uploads youd id_rsa
	
	create_network: creates  network 

	create_router: creates router

	default_sec_group: sets up inbound rules for the default security group

	create_docker: install & launches DockerInstances
	
	create_ost: run all functions


