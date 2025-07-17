# Helm Chart Enhancements

1. **Unit Testing**
- Tests cover:
    - Disabling replicas when Horizontal Pod Autoscaler (HPA) is enabled.
    - Not rendering Ingress resources when ingress is disabled.
    - Failure scenario when image repository is missing.

2. **Schema Validation**
- Introduced a `values.schema.json` file to validate user input values during install or upgrade.

3. **Kyverno Policy**
- Added a Kyverno ClusterPolicy to audit usage of container image repositories.
- Restricts pods to use images only from allowed repositories, improving security posture.

4. **Helm Hooks**
- Implemented pre-install and post-install hooks:
    - Pre-install hook runs Django database migrations via a Kubernetes Job.
    - Post-install hook performs a simple health check using a curl command.

## Benefits

- Enforced input correctness reduces runtime failures.
- Security enhanced by image repository restrictions.
- Automation hooks can simplify deployment workflows.