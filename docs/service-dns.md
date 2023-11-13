# Service DNS 
<服务名>.<命名空间>.svc.cluster.local


## 查看 service 名称与信息
```sh
kubectl get svc  -o wide
```

## 查看 pod 名称与信息
```sh
kubectl get pod -o wide
```

## 进入pod
```sh
kubectl exec -it pod-name /bin/sh
```

### 查看 /etc/resolv.conf 文件信息

```sh
cat /etc/resolv.conf

nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5
```

### 请求 dns 
```sh
curl whoami.default.svc.cluster.local
// 请求结果
Hostname: whoami-78c854646d-nhgl9
IP: 127.0.0.1
IP: 10.244.0.30
RemoteAddr: 10.244.0.74:57958
GET / HTTP/1.1
Host: whoami.default.svc.cluster.local
User-Agent: curl/7.80.0
Accept: */*
```

### ping
```sh
ping whoami.default.svc.cluster.local
```

k8s重的 statfulset 就是这种方法来指定具体的 pod，通过创建带 hostname 和 subdomain 的 pod，再配合 headless service 实现指向具体的pod

集群域名	命名空间	服务名	StatefulSet	StatefulSet DNS	Pod 主机名	Pod DNS
cluster.local	default 	nginx	web	nginx.default.svc.cluster.local	web-0	web-0.nginx.default.svc.cluster.local
kube.local	rcmd	        nginx	web	nginx.rcmd.svc.kube.local	web-0	web-0.nginx.rcmd.svc.kube.local


