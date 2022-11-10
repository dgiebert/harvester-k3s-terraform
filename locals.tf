# For better readability
locals {
  cluster_name          = coalesce(var.cluster.name, "staging")
  k3s_version           = coalesce(var.cluster.k3s_version, "v1.24.4+k3s1")
  labels                = coalesce(var.cluster.labels, {})
  server_args           = coalesce(var.cluster.server_args, "--etcd --controlplane --label 'cattle.io/os=linux'")
  agent_args            = coalesce(var.cluster.agent_args, "--worker --label 'cattle.io/os=linux'")
  harvester_kube_config = var.harvester_kube_config != "" ? var.harvester_kube_config : "${path.root}/harvester.kubeconfig"
  vlan_name             = var.vlan_name != "" ? var.vlan_name : "vlan-${local.cluster_name}-${var.vlan_id}"

  server_vms = {
    number      = coalesce(var.server_vms.number, 3)
    cpu         = coalesce(var.server_vms.cpu, 4)
    memory      = coalesce(var.server_vms.memory, "16Gi")
    disk_size   = coalesce(var.server_vms.disk_size, "20Gi")
    auto_delete = coalesce(var.agent_vms.auto_delete, true)
  }

  agent_vms = {
    number      = coalesce(var.agent_vms.number, 0)
    cpu         = coalesce(var.agent_vms.cpu, 4)
    memory      = coalesce(var.agent_vms.memory, "16Gi")
    disk_size   = coalesce(var.agent_vms.disk_size, "20Gi")
    auto_delete = coalesce(var.agent_vms.auto_delete, true)
  }
}
