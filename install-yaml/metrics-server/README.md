# 错误处理

问题1: 在单机版k8s上部署应用后，发现Pod的状态一直处于pending状态，

```sh
 kubectl describe pods 
```
查询结果：
```sh
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  10m   default-scheduler  0/1 nodes are available: 1 node(s) had taint {node-role.kubernetes.io/master: }, that the pod didn't tolerate.
```

解决：执行命令：

```sh
kubectl taint nodes --all node-role.kubernetes.io/master-
```
