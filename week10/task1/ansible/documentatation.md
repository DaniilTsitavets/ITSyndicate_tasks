# Kubernetes Cluster Setup

## Step 1: Bastion Host and SSH Configuration

- Set up a bastion host as the jump server for accessing control plane and worker nodes.
- All nodes (control plane, workers, bastion) share the same SSH key pair.
- Used `scp` to securely copy the SSH private key to the bastion host for seamless access.
- Created an `ansible.cfg` file with default connection settings (user, private key path, host key checking disabled) to simplify running Ansible playbooks without repeatedly specifying options.

---
## Step 2: Certificate and Kubeconfig Setup

- Generated all necessary TLS certificates and kubeconfig files.

---

## Step 3: Configuring the Control Plane


- Installed and configured `kube-apiserver`, `kube-controller-manager`, and `kube-scheduler`.
- Set up encryption and RBAC policies.
- Services were enabled and started.
---

## Step 4: Setting Up Worker Nodes

- Installed container runtime (`containerd`), kubelet, and kube-proxy.
- Configured CNI networking.
- Disabled swap (required by kubelet for stability).
- Set up and started all required services.
---

## Step 5: Provisioning Pod Network Routes

- Instead of deploying a popular network plugin add-on, manually provisioned network routes between nodes to enable pod-to-pod communication across nodes.
- Created routes on each node that map the Pod CIDR ranges of other nodes via their internal IP addresses, enabling cross-node networking.

---

## Step 6: Deploying Sample Applications

- Deployed nginx pod and service to verify cluster functionality.
- Tested access to nginx service from within the cluster and externally.
---

## Challenges and Solutions

### 1. Worker Nodes Not Showing in `kubectl get nodes`

- **Issue:**  
  Running `kubectl get nodes` did not list the worker nodes.

- **Cause:**  
  The kubelet service on the worker nodes was failing due to missing dependencies. Certain required modules, certificates, or configuration files were not copied to the worker nodes during setup.

- **Resolution:**  
  Modified the Ansible playbooks to include tasks that copy the necessary dependencies and certificates from the control plane or bastion host to the worker nodes. After adding these tasks, the kubelet service started successfully, and the worker nodes appeared in the cluster.

---

### 2. Inability to Access nginx Service from Within the Cluster

- **Issue:**  
  Despite nginx pods running, it was impossible to access the nginx service from inside the cluster.

- **Cause:**  
  The kube-proxy service on the worker nodes was not running correctly because of missing dependencies or kubeconfig files. This disrupted cluster networking and prevented proper service routing.

- **Resolution:**  
  Updated the Ansible playbooks to copy kube-proxy’s configuration and certificate files onto the worker nodes. Restarting kube-proxy after this change restored its operation, and the nginx service became accessible from within the cluster.
