# Deployment Documentation

## Deployment Steps

1. **Kubernetes Cluster Setup**
    - Deployed on AWS EKS.
    - Used EC2 instances as worker nodes.
    - A total of 4 nodes were used to ensure sufficient capacity, especially for cert-manager components.
    - Checked pods distribution on nodes with:
     ```bash
     kubectl get pods -A -o wide
     ```


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

   
4. **CertManager Setup**
    - Installed cert-manager using Helm:
   ```bash
   helm repo add jetstack https://charts.jetstack.io
   helm repo update
   helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --set installCRDs=true
   ```
    - A fourth node was added because the existing three had insufficient resources for cert-manager pods (Too many pods error).
- Initial Setup Without Domain:

   - ClusterIssuer and certificate templates were included in the Helm chart from the beginning.

   - But, no domain was available initially, so the certificate could not be issued.

   - The chart was deployed without domain-related values

- Domain Configured Later:

   - After a domain (back2.cloud) was obtained, it was added to values.yaml.

   - The chart was redeployed to apply the domain and enable TLS issuance:
  ```bash
  helm upgrade --install sample-django ./helm_chart -n default
  ```
5. **Deployment with helmfile**
    - Used `helmfile` to automate Helm releases management and environment deployment.

---


## Why Kubernetes and Helm?

- **Kubernetes**  
  Provides automated scaling, self-healing, and declarative management of containerized apps, allowing robust production-grade deployments.


- **Helm**  
  Simplifies managing Kubernetes manifests by templating, parameterization, and packaging.

  Integration with sops provides solution for encrypting secrets, but ESO is anyway better.

---

## Notes

- Probes (readiness/liveness) use `/` as endpoint.
