#!/bin/bash

echo "install kube-sphere"
echo "下载 kubesphere-installer.yaml "
wget https://github.com/kubesphere/ks-installer/releases/download/v3.3.2/kubesphere-installer.yaml
echo "下载 cluster-configuration.yaml"
wget https://github.com/kubesphere/ks-installer/releases/download/v3.3.2/cluster-configuration.yaml
kubectl create ns kubesphere-system
echo "start apply"
kubectl apply -f kubesphere-installer.yaml -n kubesphere-system
kubectl apply -f cluster-configuration.yaml -n kubesphere-system
