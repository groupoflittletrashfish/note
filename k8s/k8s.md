<head>
  <style>
    .c{
      font-size: 13px;
    }
    td{
      background:powderblue
    }
    span{
      background:powderblue;
      display:inline-block;
      padding:5px
    }
  </style>
</head>

<font class=c>

### k8s概念
* 全称：Kubernetes
* k8s进行容器化部署
### 特性
* 自动装箱：构建于容器之上，基于资源依赖及其他约束自动完成容器部署且不影响其可用性，并通过调度机制混合关键型应用和非关键型应用的工作负载于同一节点以提升资源利用率。
* 自我修复（自我治愈）：支持容器故障后自动重启、节点故障后重新调度容器，以及其他可用节点、健康状态检查失败后关闭容器并重新创建等自我修复机制。
* 水平扩展：支持通过简单命令或UI手动水平扩展，以及基于CPU等资源负载率的自动水平扩展机制。
* 服务发现和负载均衡：k8s通过其附件组件之一的KubeDNS(或CoreDNS)为系统内置了服务发现功能，它会为每个service配置DNS名称，并允许集群内的客户端直接使用此名称发出访问请求，而service则通过iptables或ipvs内建立负载均衡机制。
* 自动发布和回滚：k8s支持“灰度”更新应用程序或其配置信息，监控更新过程中应用程序的健康状态，以确保不会同一时间杀掉所有实例，在这个过程中一旦出现故障，立马进行回滚操作。
* 密钥和配置管理：k8s的configMap实现了参数配置和Docker镜像的解耦，修改配置时无需重新build镜像，这为应用开发部署带来了很大的灵活性。另外，对于应用依赖的一些敏感数据，如用户名和密码、令牌、密钥等，k8s专门提供了Secret对象为其解耦。
* 存储编排：k8s支持Pod对象按需自动挂载不同类型的存储系统,包括节点的本地存储系统，云存储（AWS），网络存储系统（NFS、GlusterFS）。
* 批量处理执行：除了服务型应用，k8s还支持批处理作业及CI(持续集成)，如果需要，一样可用实现容器故障后恢复
### 组件
![附图](./ks8架构图.png)
* **Master**:主控节点
  * <font color = 'red'>apiServer</font>：集群统一入口，以Restful方式，交给etcd存储，类似于网关
  * <font color = 'red'>scheduler</font>：节点调度，选择node节点应用部署
  * <font color = 'red'>controller-manager</font>：处理集群中常规的后台任务，一个资源对应一个控制器
  * <font color = 'red'>etcd</font>：存储系统，用于保存集群中相关的数据
* **Node**:工作节点
  * kubeelet：Master派遣到Node上的节点代表，管理本机中的容器
  * kube-proxy：提供网络代理，负载均衡等操作

### 核心概念
  * **pod** 
    * 最小部署单位
    * 一组容器的集合
    * pod之间的容器是共享网络的
    * 生命周期是短暂的
  * **Controller**
    * 能够确保预期的pod副本数量
    * 无状态应用部署：可以简单理解为可以直接使用的容器
    * 有状态应用部署：可以简单理解为需要满足特定条件才可以使用的容器
    * 确保所有的Node运行同一个pod
    * 一次性任务和定时任务
  * **service** 
    * 定义一组pod的访问规则
    * 简单流程来讲：service作为入口，通过controller来创建pod进行部署
### 集群的部署（kubeamd方式，推荐）
  1. 集群的结构为1个Master+2个Node
  2. Master：192.168.238.130，Node：192.168.238.131，192.168.238.132
  3. 关闭selinux，一种为临时关闭，另一种为永久关闭，建议两种都用
      * 临时关闭：setenforce 0  
      * 永久关闭：sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config ，<font color = 'red'>**需要重启**</font>  
  4. 使用命令：sestatus查看状态
  5. 关闭swap分区，同样有临时和永久关闭两种
      * 临时关闭：swapoff -a
      * 永久关闭：sed -ri 's/.*swap.*/#&/' /etc/fstab
  6. 为三台服务器设置对用的host名称，好区分
      * Master服务器：hostnamectl set-hostname k8smaster
      * Node服务器（131）：hostnamectl set-hostname k8snode1
      * Node服务器（132）：hostnamectl set-hostname k8snode2
  7. <font color=red>在Master服务器</font>上更改hosts文件，追加三台服务器的地址和名称
     ```
     cat >> /etc/hosts <<EOF 
     192.168.238.130 k8smaster
     192.168.238.131 k8snode1
     192.168.238.132 k8snode2
     EOF
     ``` 
 8. 时间同步
    * 安装插件：yum install ntpdate -y 
    * 同步：ntpdate time.windows.com
 9. 在三台服务器上都安装Docker(可以参看印象笔记中的docker安装)
10. 在三台服务器上都安装kubelet,kubeadm,kubectl
    * 如果yum没有更改过yum源，则需要更改，此处以阿里的源为主
    * ```
      cat > /etc/yum.repos.d/kubernetes.repo << EOF 
      [kubernetes]
      name=Kubernetes
      baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
      enabled=1
      gpgcheck=0
      repo_gpgcheck=0
      gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
      EOF
      ```
    * yum install -y kubelet-1.18.0 kubeadm-1.18.0 kubectl-1.18.0
    * 安装完成后设置为开机启动：systemctl enable kubelet
11. <font color = red>**在Master服务器上**</font>执行初始化操作
 
    ```
    kubeadm init --apiserver-advertise-address=192.168.238.130 --image-repository registry.aliyuncs.com/google_containers --kubernetes-version v1.18.0 --service-cidr=10.96.0.0/12 --pod-network-cidr=10.244.0.0/16
    ```
    * --apiserver-advertise-address=192.168.238.130：即Master的地址
    * --image-repository registry.aliyuncs.com/google_containers：镜像地址，就用阿里的
    * --kubernetes-version v1.18.0：kubernetes的版本号，即刚才yum安装指定的版本
    * --service-cidr=10.96.0.0/12：就用这个就可以了，好像挺随意的
    * --pod-network-cidr=10.244.0.0/16：就用这个就可以了，好像挺随意的
    * <span>执行以上命令以后可能会失败，注意是有硬件要求的。至少必须是2核以上的处理器</span>
    * 完成后可以使用docker images查看，多出很多镜像
    * 还是会有可能失败的，若容易出现的错误就是kubelet-check] Initial timeout of 40s passed.如果出现这个错误，先使用<font color=red>**kubeadm reset**</font>命令重置，然后再执行kubeadm init --kubernetes-version v1.18.0 --service-cidr=10.96.0.0/12 --pod-network-cidr=10.244.0.0/16，和原本的命令基本一样，至是去掉了两个参数--image-repository和--apiserver-advertise-address
    * 虚拟机太卡，学不下去。视频看到第7集，在百度云中的架构相关->尚硅谷Kubernetes(k8s)新版
