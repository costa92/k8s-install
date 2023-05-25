#!/bin/bash
tee /etc/apt/sources.list.d/kubernetes.list <<EOF
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

apt-get update &&

source manifests/environment.sh &&

echo ">>> ${K8S_VERSION}" &&
echo "install k8s"  &&
apt-get install -y kubelet=${K8S_VERSION} kubeadm=${K8S_VERSION} kubectl=${K8S_VERSION} --allow-unauthenticated &&

systemctl enable kubelet && systemctl start kubelet &&

echo "end install k8s" &&
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add  &&


echo "kubeadm" &&
kubeadm init \
  --image-repository registry.aliyuncs.com/google_containers \
  --kubernetes-version v1.23.17 \
  --service-cidr=10.96.0.0/12 \
  --pod-network-cidr=10.244.0.0/16 \
  --ignore-preflight-errors=all  &&

echo "config"
mkdir -p $HOME/.kube &&
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config &&
sudo chown $(id -u):$(id -g) $HOME/.kube/config &&

echo "install kube-flannel"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml 



