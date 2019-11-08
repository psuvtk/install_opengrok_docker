#!/bin/bash

GROKPATH=/opengrok
CONTAINER_NAME=opengrok
PORT=8888
REINDEX="0"

function pr_info()
{
	echo -e "\033[32m" $1 "\033[0m"
}

# install docker community edition and pull opengrok official image
function install()
{
	sudo apt install -y curl
	sudo apt remove docker docker-engine docker.io containerd runc
	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
	sudo apt-key fingerprint 0EBFCD88
	sudo add-apt-repository \
	   "deb [arch=amd64] https://download.docker.com/linux/debian \
	   $(lsb_release -cs) \
	   stable"
	sudo apt update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io
	sudo docker pull opengrok/docker
	sudo mkdir -p $GROKPATH/etc
	sudo mkdir -p $GROKPATH/data
	sudo mkdir -p $GROKPATH/src
	pr_info "\nDone!"
}

function run()
{
	echo "check exist docker opengrok..."
	sudo docker stop $CONTAINER_NAME
	sudo docker rm $CONTAINER_NAME

	echo "delete existing data and etc..."
	sudo rm -rf $GROKPATH/etc/*
	sudo rm -rf $GROKPATH/data/*
	
	echo "run docker image opengrok/docker:latest"
	sudo docker run -d  \
	    --name $CONTAINER_NAME \
	    -p $PORT:8080/tcp \
	    -e REINDEX=$REINDEX \
	    -v $GROKPATH/src/:/opengrok/src/ \
	    -v $GROKPATH/etc/:/opengrok/etc/ \
	    -v $GROKPATH/data/:/opengrok/data/ \
	    opengrok/docker:latest
	pr_info "\n opengrok/docker running."	
}

# Reindex When you add some new Project 
function reindex()
{
	sudo docker exec opengrok /scripts/index.sh
	pr_info "\nDone!"
}

function usage()
{
	echo -e "\033[31m" "\nusage:" "\t./opengropk.sh [install|run|reindex|usage]"
	echo -e "\tinstall\t install docker community edition and opengrok official image"
	echo -e "\trun\trun opengrok at specific port"
	echo -e "\treindex\treindex when you add some new project in \${GROKPATH}/src directory"
	echo -e "\033[0m"
}

if [ $# -eq 0 ]; then 
	usage
fi

case $1 in
	"install")
		install	
		;;
	"run")
		run
		;;
	"reindex")
		reindex
		;;
	*)
		usage
		;;
esac