# ansible-kubernetes-setup

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
