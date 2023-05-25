#!/bin/bash
cp docker.json /etc/docker/daemon.json &&
systemctl enable docker && systemctl start docker 
