output "virtual_machines" {
  value       = module.nodes.virtual_machines
  description = "The provisioned virtual machines on harvester. (Format: [harvester_virtualmachine](https://registry.terraform.io/providers/harvester/harvester/latest/docs/data-sources/virtualmachine))"
}

output "clusterInfo" {
  value = {
    name             = local.cluster_name
    labels           = local.cluster_name
    k3s_version      = local.k3s_version
    server_args      = local.server_args
    agent_args       = local.agent_args
    registration_url = local.registration_url
  }
  description = "Combined output to be used with other providers/modules (Format: [clusterInfo](#input_clusterInfo))"
}
