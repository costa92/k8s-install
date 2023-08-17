# KubeSphere

# Install KubeSphere
```bash
./install.sh
```

注意如果有私有仓库：

私有仓库地址： `dockerhub.kubekey.local`

```bash
sed -i "s#^\s*image: kubesphere.*/ks-installer:.*#        image: dockerhub.kubekey.local/kubesphere/ks-installer:v3.0.0#" kubesphere-installer.yaml
```


```bash
chmod +x kubesphere-delete.sh && 
./kubesphere-delete.sh
```
