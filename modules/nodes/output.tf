output "virtual_machines" {
  value       = harvester_virtualmachine.servers[*]
  description = "The provisioned virtual machines on harvester. (https://registry.terraform.io/providers/harvester/harvester/latest/docs/data-sources/virtualmachine)"
}

output "ips" {
  value       = harvester_virtualmachine.servers[*].network_interface[0].ip_address
  description = "The provisioned virtual machines on harvester. (https://registry.terraform.io/providers/harvester/harvester/latest/docs/data-sources/virtualmachine)"
}