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


问题：
```sh
# 报错
TASK [preinstall : KubeSphere | Stopping if default StorageClass was not found] ***
fatal: [localhost]: FAILED! => {
    "assertion": "\"(default)\" in default_storage_class_check.stdout",
    "changed": false,
    "evaluated_to": false,
    "msg": "Default StorageClass was not found !"
}

PLAY RECAP *********************************************************************
localhost                  : ok=4    changed=2    unreachable=0    failed=1    skipped=4    rescued=0    ignored=0
```
解决问题：
```sh
cat >> default-storage-class.yaml <<-EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local
  annotations:
    cas.openebs.io/config: |
      - name: StorageType
        value: "hostpath"
      - name: BasePath
        value: "/var/openebs/local/"
    kubectl.kubernetes.io/last-applied-configuration: >
      {"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{"cas.openebs.io/config":"-
      name: StorageType\n  value: \"hostpath\"\n- name: BasePath\n  value:
      \"/var/openebs/local/\"\n","openebs.io/cas-type":"local","storageclass.beta.kubernetes.io/is-default-class":"true","storageclass.kubesphere.io/supported-access-modes":"[\"ReadWriteOnce\"]"},"name":"local"},"provisioner":"openebs.io/local","reclaimPolicy":"Delete","volumeBindingMode":"WaitForFirstConsumer"}
    openebs.io/cas-type: local
    storageclass.beta.kubernetes.io/is-default-class: 'true'
    storageclass.kubesphere.io/supported-access-modes: '["ReadWriteOnce"]'
provisioner: openebs.io/local
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOF
kubectl apply -f default-storage-class.yaml
```
删除重新安装
参考：https://ask.kubesphere.io/forum/d/7194-kubekeyk8skubesphere-default-storageclass-was-not-found
