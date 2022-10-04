module "cluster" {
  source                = "./modules/cluster"
  cluster_name          = coalesce(var.cluster.name, "staging")
  k3s_version           = coalesce(var.cluster.k3s_version, "v1.24.4+k3s1")
  rancher2              = var.rancher2
  enable_network_policy = true # Experimental
}

module "nodes" {
  source                = "./modules/nodes"
  cluster_name          = coalesce(var.cluster.name, "staging")
  ssh_keys              = var.ssh_keys
  namespace             = var.namespace
  harvester_kube_config = local.harvester_kube_config
  vlan_id               = var.vlan_id
  server_vms            = local.server_vms # Defaults specified in locals.tf
  agent_vms             = local.agent_vms  # Defaults specified in locals.tf
  registration_url      = module.cluster.registration_url
  server_args           = coalesce(var.cluster.server_args, "--etcd --controlplane --label 'cattle.io/os=linux'")
  agent_args            = coalesce(var.cluster.agent_args, "--worker --label 'cattle.io/os=linux'")
}

