# 使用 Operator 部署 Istio

1. 下载 Istio

```sh
> wget https://github.com/istio/istio/releases/download/1.15.6/istio-1.15.6-linux-amd64.tar.gz
```
2. 解压安装

```sh
> tar xf istio-1.15.6-linux-amd64.tar.gz
> cd istio-1.15.6
> sudo cp bin/istioctl /usr/local/bin/
```
3. 查看安装版本

```sh
> istioctl version
no running Istio pods in "istio-system"
1.15.6
```
4. 安装 Istios 的 Operator,可以一键部署

```sh
> istioctl operator init
Operator controller is already installed in istio-operator namespace.
Upgrading operator controller in namespace: istio-operator using image: docker.io/istio/operator:1.15.6
Operator controller will watch namespaces: istio-system
✔ Istio operator installed
✔ Installation complete
```
5. 安装 Istio
```sh
> istioctl manifest apply -f istio-operator.yaml
This will install the Istio 1.15.6 default profile with ["Istio core" "Istiod" "Ingress gateways"] components into the cluster. Proceed? (y/N) y
✔ Istio core installed
✔ Istiod installed
✔ Ingress gateways installed
✔ Installation complete                                                                                                                                       Making this installation the default for injection and validation.

Thank you for installing Istio 1.15.  Please take a few minutes to tell us about your install/upgrade experience!  https://forms.gle/SWHFBmwJspusK1hv6
```
6. 查看是否安装成功
```sh
> kubectl get po -n istio-system
NAME                                    READY   STATUS    RESTARTS   AGE
istio-ingreegateway-78cb4f87b9-bfhhg    1/1     Running   0          5m4s
istio-ingressgateway-5f468978c7-8864d   1/1     Running   0          5m4s
istiod-58bf7fcffb-4zlgg                 1/1     Running   0          6m58s
```
如果没有成，重新执行 `istioctl manifest apply -f istio-operator.yaml` 命令

7. 查看创建的 Service与Pod：
```sh
> kubectl get svc,pod -n istio-system
NAME                           TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                                      AGE
service/istio-ingreegateway    NodePort       10.110.160.125   <none>        15020:30520/TCP,80:30080/TCP,443:30443/TCP   7m41s
service/istio-ingressgateway   LoadBalancer   10.96.18.128     <pending>     15021:32445/TCP,80:31488/TCP,443:32230/TCP   7m41s
service/istiod                 ClusterIP      10.100.142.61    <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP        9m35s

NAME                                        READY   STATUS    RESTARTS   AGE
pod/istio-ingreegateway-78cb4f87b9-bfhhg    1/1     Running   0          7m41s
pod/istio-ingressgateway-5f468978c7-8864d   1/1     Running   0          7m41s
pod/istiod-58bf7fcffb-4zlgg                 1/1     Running   0          9m35s
```

### 注意 在k8s v1.16 之前的需要 配置自动注入
修改 APIService的配置文件，添加 MutatingAdmissionWebhook, ValidatingAdmissionWebhook (如果大于 1.16版本 默认是开启)
```sh
> vim  /etc/kubernetes/manifests/kube-apiservice.yaml   # 二进制安装方式需要找 APIService 的Service 文件
  # 添加内容：
   - --enable-admission-plugins=MutatingAdmissionWebhook,ValidatingAdimssionWebhook # 其他的不变，只需添加这个两个配置即可
```
测试：
```sh
> kubectl create ns istio-test
> kubectl label namespace istio-test istio-injection=enabled # 给空间添加标签
```
 切换目录到 istio 的安装包，然后创建测试应用，此时创建的Pod 会被自动注入 一个 istio-proxy 的容器：
```sh
 > kubectl apply -f samples/sleep/sleep.yaml -n istio-test
 service/sleep create
 deploment.extensions/sleep created
```
查看容器
```sh
> kubectl get po -n istio-test
```

8. 安装可视化 Kiali
Kiali 为 Istio 提供可视化的界面，可以在Kiail上进行观测流量的走向，调用链，同时还有可以使用 Kiail进行配置管理，给用户带来很好的体验  

进入 Istio的安装包目录执行：
```sh
> kubectl apply -f samples/addons/kiali.yaml
serviceaccount/kiali created
configmap/kiali created
clusterrole.rbac.authorization.k8s.io/kiali-viewer created
clusterrole.rbac.authorization.k8s.io/kiali created
clusterrolebinding.rbac.authorization.k8s.io/kiali created
role.rbac.authorization.k8s.io/kiali-controlplane created
rolebinding.rbac.authorization.k8s.io/kiali-controlplane created
service/kiali created
deployment.apps/kiali created
```
查看部署状态：
```sh
> kubectl get po,svc -n istio-system -l app=kiali
NAME                         READY   STATUS              RESTARTS   AGE
pod/kiali-689fbdb586-59kmt   0/1     ContainerCreating   0          77s

NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)              AGE
service/kiali   ClusterIP   10.106.91.78   <none>        20001/TCP,9090/TCP   77s
```

9. 安装 trace(链路跟踪)  jaeger
```sh
> kubectl create -f samples/addons/jaeger.yaml
deployment.apps/jaeger created
service/tracing created
service/zipkin created
service/jaeger-collector created
```

10. 安装 Prometheus 与 Grafana
```sh
> kubectl create -f samples/addons/prometheus.yaml -f samples/addons/grafana.yaml
```

## 部署 bookinfo 测试

1. 创建空间 bookinfo
```sh
> kubectl create ns bookinfo
```
2. 给空间添加一个 label
```sh
> kubectl label ns bookinfo istio-injection=enabled
```
3. 安装 bookinfo 
```sh
> kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml -n bookinfo
service/details created
serviceaccount/bookinfo-details created
deployment.apps/details-v1 created
service/ratings created
serviceaccount/bookinfo-ratings created
deployment.apps/ratings-v1 created
service/reviews created
serviceaccount/bookinfo-reviews created
deployment.apps/reviews-v1 created
deployment.apps/reviews-v2 created
deployment.apps/reviews-v3 created
service/productpage created
serviceaccount/bookinfo-productpage created
deployment.apps/productpage-v1 created
```
4. 查看安装的bookinfo的 pod与svc
```sh
> kubect get po,svc -n bookinfo
NAME                                 READY   STATUS            RESTARTS   AGE
pod/details-v1-698b5d8c98-twhxk      2/2     Running           0          3m7s
pod/productpage-v1-bf4b489d8-hqktr   0/2     PodInitializing   0          3m7s
pod/ratings-v1-5967f59c58-zh2xf      0/2     PodInitializing   0          3m7s
pod/reviews-v1-9c6bb6658-ngmkz       0/2     PodInitializing   0          3m7s
pod/reviews-v2-8454bb78d8-mtfd9      0/2     PodInitializing   0          3m7s
pod/reviews-v3-6dc9897554-cggjt      0/2     PodInitializing   0          3m7s

NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/details       ClusterIP   10.110.123.250   <none>        9080/TCP   3m7s
service/productpage   ClusterIP   10.111.179.35    <none>        9080/TCP   3m7s
service/ratings       ClusterIP   10.105.63.55     <none>        9080/TCP   3m7s
service/reviews       ClusterIP   10.99.185.56     <none>        9080/TCP   3m7s
```
注意：Reviews Pod 有三个版本，生产环境，是不会同时存在 三个版本的 

5. 部署 Gateway 与 VirtualService 
修改官方示例的域名：
```sh
> vim samples/bookinfo/networking/book-gateway.yaml
...
 hosts:
 - "bookinfo.costalong.cn"
---
 hosts
 - "bookinfo.costalong.cn"
# 创建资源
> kubectl create -f samples/bookinfo/networking/bookinfo-gateway.yaml -n bookinfo
```
6. 查看安装的资源
```sh
> kubectl get gw,vs -n bookinfo
NAME                                           AGE
gateway.networking.istio.io/bookinfo-gateway   75s

NAME                                          GATEWAYS               HOSTS                       AGE
virtualservice.networking.istio.io/bookinfo   ["bookinfo-gateway"]   ["bookinfo.costalong.cn"]   75s
```
 将域名 bookinfo.costalong.cn 进行解析到集群任意安装 kube-proxy 的节点Ip上
