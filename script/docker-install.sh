#!/usr/bin/env bash

# docker rmeove
docker::uninstall() {
	for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
}

docker::install() {
	sudo apt-get update
	sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	sudo apt-get update
	sudo apt-get install -y docker-ce

	docker::group

	systemctl enable docker
	systemctl start docker
}

docker::version() {
	docker --version
}

docker::run() {
	systemctl start docker
}

docker::stop() {
	systemctl stop docker
}

# 修改用户组
docker::group() {
	sudo groupadd docker
	sudo usermod -aG docker $USER
	sudo chmod a+rw /var/run/docker.sock
}

if [[ "$*" =~ docker:: ]]; then
	eval $*
fi
