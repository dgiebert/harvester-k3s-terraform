resource "rancher2_cloud_credential" "aws-s3" {
  count = var.s3_credential_config.access_key != "" ? 1 : 0
  name  = "aws-s3"
  s3_credential_config {
    access_key     = var.s3_credential_config.access_key
    secret_key     = var.s3_credential_config.secret_key
    default_bucket = var.s3_credential_config.default_bucket
    default_region = var.s3_credential_config.default_region
  }
}

# Create a K3S Cluster
resource "rancher2_cluster_v2" "default" {
  name                  = var.cluster_name
  kubernetes_version    = var.k3s_version
  enable_network_policy = var.enable_network_policy # Experimental
  labels                = var.labels

  rke_config {
    additional_manifest   = local.additional_manifest
    machine_global_config = <<-EOF
      secrets-encryption: true
      kube-controller-manager-arg:
      - terminated-pod-gc-threshold=10
      - use-service-account-credentials=true
      kube-apiserver-arg:
      - enable-admission-plugins=NodeRestriction,NamespaceLifecycle,ServiceAccount
      - audit-log-path=/var/lib/rancher/k3s/server/logs/audit.log
      - audit-policy-file=/var/lib/rancher/k3s/server/audit.yaml
      - audit-log-maxage=30
      - audit-log-maxbackup=10
      - audit-log-maxsize=100
      - request-timeout=300s
      - service-account-lookup=true
    EOF
    etcd {
      disable_snapshots      = false
      snapshot_schedule_cron = var.snapshot_schedule_cron
      snapshot_retention     = var.snapshot_retention
      dynamic "s3_config" {
        for_each = rancher2_cloud_credential.aws-s3
        content {
          bucket                = s3_config.value.s3_credential_config[0].default_bucket
          endpoint              = "s3.${s3_config.value.s3_credential_config[0].default_region}.amazonaws.com"
          region                = s3_config.value.s3_credential_config[0].default_region
          folder                = var.cluster_name
          cloud_credential_name = s3_config.value.id
        }
      }
    }
  }
}
