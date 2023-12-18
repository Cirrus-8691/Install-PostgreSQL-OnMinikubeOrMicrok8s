# Install PostgreSql

<p align="center">
<img
    alt="PostgreSql-Logo"
    src="../../../assets/postgresql.svg"
    height="128"
/><br>
</p>

# Use bitnami/postgresql

https://github.com/bitnami/charts/tree/main/bitnami/postgresql

With the standard installation, when **Minikube** restart ( when laptop or server reboot), the **StatefulSet** and **Deployment** failed to start with a message "Back-off restarting failed container", because her **Container** cannot read/write on default **StorageClass** forof the previously used **PersistentVolume**.

# Customised install

We use a **StorageClass** with **reclaimPolicy: Retain**, to keep data when the server/laptop, where Minikube is running, reboot.
As Bitnami chart container run as user 1001 in goup 1001 we have to change default file acces mode of the **PersistentVolume** hostPath.

```bash
cd networking
./install.sh project1 192.168.0.24
```

# Uninstall
```bash
helm -n payinnov-postgresql uninstall postgresql
```