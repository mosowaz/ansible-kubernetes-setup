# ansible-kubernetes-setup

For complete plays, run the main.yml playbook
```
ansible-playbook main.yml -i inventory.yml
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

` ansible all -m command -a "free -h" `

## Step 2
Run the playbook for installing kubeadm, kubectl, and kubelet

` ansible-playbook kube-pkg-installs.yml -i inventory.yml ` 
