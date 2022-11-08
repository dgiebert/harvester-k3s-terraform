# Create a K3S Cluster
resource "rancher2_cluster_v2" "default" {
  name                  = var.cluster_name
  kubernetes_version    = var.k3s_version
  enable_network_policy = var.enable_network_policy # Experimental
  labels                = var.labels
}
