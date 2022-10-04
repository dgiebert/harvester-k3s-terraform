output "virtual_machines" {
  value       = harvester_virtualmachine.servers[*]
  description = "The provisioned virtual machines on harvester. (https://registry.terraform.io/providers/harvester/harvester/latest/docs/data-sources/virtualmachine)"
}