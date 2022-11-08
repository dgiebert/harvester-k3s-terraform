output "virtual_machines" {
  value       = module.nodes.virtual_machines
  description = "The provisioned virtual machines on harvester. (https://registry.terraform.io/providers/harvester/harvester/latest/docs/data-sources/virtualmachine)"
}

output "ips" {
  value       = module.nodes.ips
  description = "The URL used to provision new nodes"
}

output "clusterInfo" {
  value = {
    name             = local.cluster_name
    k3s_version      = local.k3s_version
    server_args      = local.server_args
    agent_args       = local.agent_args
    registration_url = module.cluster.registration_url
  }
  description = "Combined output to be used with other providers/modules"
}
