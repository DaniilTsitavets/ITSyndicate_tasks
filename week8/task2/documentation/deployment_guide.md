# Deployment Documentation

## Deployment Steps

- **Platform**: AWS Elastic Kubernetes Service (EKS)
- **OIDC Provider**: Enabled and associated with the EKS cluster:
- **IRSA (IAM Roles for Service Accounts)**: Configured to securely grant IAM permissions to Kubernetes workloads without using node instance roles.
- **IAM Roles**:
- `AmazonEKSClusterPolicy` for EKS control plane role.
- `AmazonEKSWorkerNodePolicy`, `AmazonEBSCSIDriverPolicy`, and others for node role.
- Additionally, **IRSA role** (AmazonEKS_EBS_CSI_Driver_IRSA) with `AmazonEBSCSIDriverPolicy` was created for the CSI driver as showed here: [Use Kubernetes volume storage with Amazon EBS](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html).

1. AWS EBS CSI Driver Installation
- Required the IRSA setup for the CSI driver to authenticate to the EBS API.
- Installed via Helm using the official AWS EBS CSI Driver chart.
```bash
 helm upgrade --install aws-ebs-csi-driver \                       
  aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system \
  --set controller.serviceAccount.create=true \
  --set controller.serviceAccount.name=ebs-csi-controller-sa \
  --set controller.serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::<acc_id>:role/AmazonEKS_EBS_CSI_Driver_IRSA
```
- Mounted EBS volumes dynamically using PersistentVolumeClaims.

2. **NGINX Ingress Controller Installation**
    - Installed via Helm from the official repo.
    - Service type: LoadBalancer, providing external access.
    - Installed via Helm:
     ```bash
     helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
     helm repo update
     helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
     ```
    - Verified the service and external IP with:
     ```bash
     kubectl get svc -n ingress-nginx
     ```

3. **Application Deployment with Helm**
    - Created a Helm chart including Deployment, Service, and Ingress.
    - Added readiness and liveness probes.
    - Configured HorizontalPodAutoscaler to scale replicas from 2 to 4 based on CPU usage (80% threshold).
    - Deployed the application using:
     ```bash
     helm upgrade --install django ./helm_chart -n default
     ```
    - Or with helmfile:
     ```bash
     helmfile apply
     ```