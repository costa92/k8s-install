#!/usr/bin/env bash

if [ -f /usr/local/bin/containerd ]; then
	echo "containerd already installed"
	exit 0
fi

if [ ! -f containerd-1.7.14-linux-amd64.tar.gz ]; then
	wget https://github.com/containerd/containerd/releases/download/v1.7.14/containerd-1.7.14-linux-amd64.tar.gz
fi

sudo tar xvf containerd-1.7.14-linux-amd64.tar.gz -C /usr/local/

if [ ! -f /etc/containerd ]; then
	sudo mkdir /etc/containerd
fi

containerd config default >/etc/containerd/config.toml
