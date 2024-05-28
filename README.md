# ansible-kubernetes-setup
The purpose of this project is to demonstrate the setup of kubernetes cluster.
There will be High Availabilty incorperated into the cluster (2 master nodes and 2 worker nodes).

For complete kubernetes cluster playbook, run the main.yml
```
$ ansible-playbook main.yml -i inventory.yml
```

For individual play, each step is listed below. 
## Step 1
Remove swap from Master and Worker nodes
```
- hosts: all
  tasks:
  
    - name: Remove swap from "/etc/fstab"
      lineinfile:
        path: /etc/fstab
        regexp: /swap.imp*
        state: absent
        backup: yes
      
    - name: Run swappoff command on hosts
      command: swapoff -a
```
Confirm that swap is removed by running ad-hoc command

`$ ansible all -m command -a "free -h" `

## Step 2
Run containerd.yml playbook to setup config files and create required files for network bridge, 
and modules (br_netfilter and overlay). Also install the Container Network Interface software (kubernetes-cni)

`$ ansible-playbook containerd.yml -i inventory.yml ` 

## Step 3
Run the playbook for installing kubeadm, kubectl, and kubelet

`$ ansible-playbook kube-pkg-installs.yml -i inventory.yml ` 

## Step 4 
Initialize the main master node (kmaster1)
```
$ sudo kubeadm init --apiserver-advertise-address=10.0.0.5 --upload-certs --pod-network-cidr=10.0.0.0/24 --control-plane-endpoint="10.0.0.10:6443"
```

Then join the 2nd master (kmaster2) to the cluster with "--contol-plane"
```
$ sudo kubeadm join 10.0.0.5:6443 --contol-plane --token ov3b0h.mbjzzpcm7v9mg69z --discovery-token-ca-cert-hash sha256:d798e91ef19a981d8f7e04195a0d593f3010edd15e487898bcec4d63f947ab23
```

Lastly, join the worker nodes (kworker1 and kworker2) with the join command without "--control-plane"

On the control plane nodes, install the Container Network (CNI) plugin.
```
$ curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml -O

$ kubectl apply -f calico.yaml
```
validate that all nodes and pods are healthy

`$ kubectl get nodes`
`$ kubectl get all -A`

To start using your cluster, you need to run the following as a regular user on the control-plane nodes
```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

----------------------------------------------------------------------------------------
## Cleanup Phase
```
sudo rm -rf /var/lib/etcd
sudo kill -9 $(ps aux | grep -v grep | grep "containerd.sock" | awk -F" " '{print $2}')
sudo kubeadm reset phase cleanup-node
```
Confirm there are no running containers by running this command

`$ ps aux | grep -v grep | grep "containerd.sock" | awk -F" " '{print $2}'`

# Troubleshooting errors on kubelet and containerd
```
$ journalctl -xeu kubelet
$ crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps -a | grep kube | grep -v pause
$ crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock logs CONTAINER_ID
```

