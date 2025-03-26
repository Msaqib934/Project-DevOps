# Create Namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

# Install Kube-Prometheus Stack
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  namespace  = var.namespace
  chart      = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "67.8.0"
}

# Install Promtail
resource "helm_release" "promtail" {
  name       = "promtail"
  namespace  = var.namespace
  chart      = "promtail"
  repository = "https://grafana.github.io/helm-charts"
  version    = "6.16.6" # Replace with your desired chart version

  values = [
    yamlencode({
      clients = [
        {
          url = "http://loki-loki-distributed-gateway/loki/api/v1/push"
        }
      ]
    })
  ]
}

#Install loki
resource "helm_release" "loki" {
  name       = "loki-distributed"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-distributed"
  namespace  =  var.namespace  # Replace with your desired namespace
  version    = "0.80.1" # Replace with the desired Loki chart version

  values = [
    <<-EOT
    
    loki:
      storageConfig:
        boltdb_shipper:
          shared_store: aws
          active_index_directory: /var/loki/index
          cache_location: /var/loki/cache
          cache_ttl: 168h
        filesystem:
          directory: /var/loki/chunks
        aws:
          s3: s3://us-east-1
          bucketnames: check321

      structuredConfig: {}

    runtimeConfig: {}

    serviceAccount:
      create: true
      name: loki
      imagePullSecrets: []
      labels: {}
      annotations:
        eks.amazonaws.com/role-arn: arn:aws:iam::824813378441:role/loki-role
      automountServiceAccountToken: true
    EOT
  ]
}