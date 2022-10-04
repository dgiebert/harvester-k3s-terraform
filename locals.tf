# For better readability
locals {
  harvester_kube_config = var.harvester_kube_config != "" ? var.harvester_kube_config : "${path.root}/harvester.kubeconfig"
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
