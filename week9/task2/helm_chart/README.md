## Kubernetes Audit Logging in Amazon EKS

### Why audit logging matters
Audit logging is essential for security, compliance, and incident response in Kubernetes. It helps track who did what, when, and from where in the cluster.

### Note about EKS
Amazon EKS does not allow direct configuration of audit logs, since the kube-apiserver is managed by AWS.

### Components

- Kubernetes Audit Logging: Configured to log all requests to the API server for security and compliance.

- Elasticsearch: Stores and indexes audit logs, allows full text search.

- Logstash: ETL which parses and transforms audit log data.

- Kibana: Provides a dashboard for visualizing and analyzing audit logs.

- Filebeat: Collects audit logs from the Kubernetes nodes and sends them to Logstash.

### Suspicious Activity Scenario

Detected multiple failed kubectl exec requests with 403 errors from unknown user. Filtered audit logs by responseStatus.code=403 in Kibana. Identified suspicious IP and user. Set alerts for similar patterns. Blocked IP and started investigation.