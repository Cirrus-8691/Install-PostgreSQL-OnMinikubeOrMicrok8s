# How to install PostgreSql as Docker image 
<p>
  <a href="./LICENSE">
      <img
        alt="license:MIT"
        src="https://img.shields.io/badge/License-MIT-blue"
      />
  </a>
  <img
      alt="Language:bash"
      src="https://img.shields.io/badge/Language-bash-green"
  />
</p>

<p align="center">
<img
    alt="PostgreSql-Logo"
    src="./assets/postgresql.svg"
    height="128"
/>
<img
    alt="docker-Logo"
    src="./assets/docker.png"
    height="128"
/>
</p>


# In Minikube or Microk8s environment

<p align="center">
<img
    alt="minikube-Logo"
    src="./assets/minikube.png"
    height="128"
/>
<img
    alt="kubernetes-Logo"
    src="./assets/kubernetes.png"
    height="128"
/>
</p>
In a single MicroK8s node.

# Using bitnami/postgresql helm chart

<p align="center">
<img
    alt="minikube-Logo"
    src="./assets/bitnami.png"
    height="128"
/>
<img
    alt="helm-Logo"
    src="./assets/helm.svg"
    height="128"
/>
</p>

https://github.com/bitnami/charts/tree/main/bitnami/postgresql


## Minikube & Microk8s single node cluster

**Container** hosted in Minikube & Microk8s single node cluster using **StorageClass** [hostpath-storage](https://microk8s.io/docs/addon-hostpath-storage), when server restart, cannot read/write the previously used **PersistentVolume**.

We use a **StorageClass** using **kubernetes.io/no-provisioner** with **reclaimPolicy: Retain**, to keep data when the server/laptop where Minikube is running, restart.

As Bitnami chart container run as user 1001 in goup 1001 we have to change default file access mode of the **PersistentVolume** hostPath.

# Customise install according to projet and server ip.
Create your own folder, in networking/values, named with the server ip, like 192.168.0.24. 

Copy there this two files and update values for your needs:
- postgresql.yaml where you can modify database name, user and password, persistence size.
- pv-postgresql.yaml where you can describe persistant volume specification like hostPath and capacity storage ( same as persistence size below).

Please note: pv-name and pv-hostPath are also present in install.sh for their creation and access rights.
 
## Minikube

```bash
#Add bitnami repo only once
sudo helm repo add bitnami https://charts.bitnami.com/bitnami
```

 ### For install on Minikube run:

```bash
cd networking/postgresql-minikube
./install.sh [projectName] [server-ip]
# where 
#  - projectName: is the name of the project for witch PostgreSql is installed
#  - server-ip: is the ip, like 192.168.0.24, who's used by Kubernetes PostgreSql service to share the database with external uses.
#      127.0.0.1 is not a valid server-ip, it will be confused with PostgreSql Docker loopback localhost ip adress.
```
Warning, if Minikube was started as super user, you have to use sudo.

Sample:
```bash
cd networking/postgresql
sudo ./install.sh cirrus-project 192.168.0.24

```

### Uninstall
```bash
helm -n [projectName]-postgresql uninstall postgresql
# where 
#  - projectName: is the name of the project for witch PostgreSql is installed
```

## Microk8s:

```bash
#Add bitnami repo only once
sudo microk8s helm repo add bitnami https://charts.bitnami.com/bitnami
```
- After openning a SSH session to one of the server of the Mick8s cluster,
- git clonet this project,
- create a folder named using the current server ip, like "192.168.0.45",
- customise install according to projet:
    - database
    - username, password
    - persistence.size
- install Postgresql with:

### Microk8s single node cluster

```bash
# using "microk8s.io/hostpath"
cd networking/postgresql-microk8s
sudo ./install-1node.sh pv-0 easiware-dev 10.0.0.7
sudo ./install-1node.sh pv-1 easiware-test 10.0.0.7

```

### Microk8s NFS, Ceph-rbd storage class
```bash
cd networking/postgresql-microk8s
# using NFS storage class (not recommanded)
sudo ./install-xnodes.sh nfs [projectName]

# using Ceph-rbd storage class
sudo ./install-xnodes.sh ceph [projectName]

```

### Uninstall
```bash
sudo microk8s helm -n [projectName]-postgresql uninstall postgresql

```

