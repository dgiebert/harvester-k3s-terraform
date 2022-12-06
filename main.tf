resource "kubernetes_namespace" "cluster-namespace" {
  metadata {
    name = local.cluster_name
  }
}

module "cluster" {
  # Do not create a cluster if we pass along an registration url
  count                  = var.clusterInfo.registration_url == null ? 1 : 0
  source                 = "./modules/cluster"
  cluster_name           = local.cluster_name
  k3s_version            = local.k3s_version
  labels                 = local.labels
  rancher2               = var.rancher2
  namespace              = local.cluster_name
  enable_network_policy  = true # Experimental
  snapshot_schedule_cron = var.snapshot_schedule_cron
  snapshot_retention     = var.snapshot_retention
  s3_credential_config   = var.s3_credential_config

}

module "nodes" {
  source           = "./modules/nodes"
  cluster_name     = local.cluster_name
  efi              = var.efi
  ssh_user         = var.ssh_user
  ssh_keys         = var.ssh_keys
  namespace        = local.cluster_name
  vlan_name        = local.vlan_name
  cluster_vlan     = var.cluster_vlan
  vlan_id          = var.vlan_id
  server_vms       = local.server_vms # Defaults specified in locals.tf
  agent_vms        = local.agent_vms  # Defaults specified in locals.tf
  registration_url = local.registration_url
  server_args      = local.server_args
  agent_args       = local.agent_args
  source_image     = var.source_image
  download_image   = var.download_image
  image_name       = var.image_name
}
