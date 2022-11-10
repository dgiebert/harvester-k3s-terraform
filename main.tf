module "cluster" {
  # Do not create a cluster if we pass along an registration url
  count                 = var.clusterInfo.registration_url == null ? 1 : 0
  source                = "./modules/cluster"
  cluster_name          = local.cluster_name
  k3s_version           = local.k3s_version
  labels                = local.labels
  rancher2              = var.rancher2
  enable_network_policy = true # Experimental
}

module "nodes" {
  source                = "./modules/nodes"
  cluster_name          = local.cluster_name
  efi                   = var.efi
  ssh_user              = var.ssh_user
  ssh_keys              = var.ssh_keys
  namespace             = var.namespace
  vlan_name             = local.vlan_name
  cluster_vlan          = var.cluster_vlan
  harvester_kube_config = local.harvester_kube_config
  vlan_id               = var.vlan_id
  domain                = var.domain
  server_vms            = local.server_vms # Defaults specified in locals.tf
  agent_vms             = local.agent_vms  # Defaults specified in locals.tf
  registration_url      = local.registration_url
  server_args           = local.server_args
  agent_args            = local.agent_args
}
