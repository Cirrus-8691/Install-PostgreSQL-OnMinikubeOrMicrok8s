# Install PostgreSql as Docker image

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


# In Minikube Kubernetes

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

With the standard installation, when **Minikube** restart ( when laptop or server reboot), the **StatefulSet** and **Deployment** failed to start with a message "Back-off restarting failed container", because its **Container** cannot read/write on default **StorageClass** of the previously used **PersistentVolume**.

# Customised install

We use a **StorageClass** with **reclaimPolicy: Retain**, to keep data when the server/laptop, where Minikube is running, reboot.
As Bitnami chart container run as user 1001 in goup 1001 we have to change default file acces mode of the **PersistentVolume** hostPath.

See the networking/values directory who contain for each server-ip, like 192.168.0.24, a folder with two files:
- postgresql.yaml where you can modify database name, user and password, persistence size.
- pv-postgresql.yaml where you can describe persistant volume specification like hostPath and capacity storage ( same as persistence size below).

# How to install

```bash
cd networking/postgresql
./install.sh [projectName] [server-ip]
# where 
#  - projectName: is the name of the project for witch PostgreSql is installed
#  - server-ip: is the ip, like 192.168.0.24, who's used by Kubernetes PostgreSql Service to share the database with external uses.
#      127.0.0.1 is not a valid server-ip, it will be confused with PostgreSql Docker loopback localhost ip adress.
```
Warning, if Minikube was started as super user, you have to use sudo.
Sample:
```bash
cd networking/postgresql
sudo ./install.sh cirrus-project 192.168.0.24
```

# Uninstall
```bash
helm -n [projectName]-postgresql uninstall postgresql
# where 
#  - projectName: is the name of the project for witch PostgreSql is installed
```

Sample:
```bash
helm -n cirrus-project-postgresql uninstall postgresql

```