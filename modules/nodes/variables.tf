variable "namespace" {
  description = "The namespace resources get deployed to within Harvester"
  type        = string
  default     = "harvester-public"
}

variable "harvester_kube_config" {
  description = "The location to check for the kubeconfig to connect to Harverster"
  type        = string
  default     = ""
}

variable "vlan_id" {
  description = "The VLAN ID used to connect the VMs"
  type        = number
  default     = 2
  validation {
    condition     = var.vlan_id > 1 && var.vlan_id < 4095
    error_message = "VLAN ID must be in the rang [2-4094]"
  }
}

variable "server_vms" {
  description = "Configuration for the server nodes "
  type = object({
    number      = optional(number)
    cpu         = optional(number)
    memory      = optional(string)
    disk_size   = optional(string)
    auto_delete = optional(bool)
  })
  default = {
    number    = 3
    cpu       = 4
    memory    = "16Gi"
    disk_size = "20Gi"
    auto_delete = true
  }
  validation {
    condition     = coalesce(var.server_vms.number, 3) > 0
    error_message = "Cluster must have at least one node"
  }
  validation {
    condition     = coalesce(var.server_vms.number, 3) % 2 == 1
    error_message = "Cluster must have an uneven number of server nodes"
  }
  validation {
    condition     = var.server_vms.cpu == null || var.server_vms.cpu >= 2
    error_message = "Cluster must have at least two cores"
  }
  validation {
    condition     = var.server_vms.memory == null || can(regex("^\\d+(Gi|Mi)$", var.server_vms.memory))
    error_message = "Cluster must have at least 2Gi"
  }
  validation {
    condition     = var.server_vms.disk_size == null || can(regex("^\\d+(Gi|Mi)$", var.server_vms.disk_size))
    error_message = "Nodes must have at least 20Gi"
  }
}

variable "agent_vms" {
  description = "Configuration for the agent nodes "
  type = object({
    number      = optional(number)
    cpu         = optional(number)
    memory      = optional(string)
    disk_size   = optional(string)
    auto_delete = optional(bool)
  })
  default = {
    number    = 0
    cpu       = 2
    memory    = "4Gi"
    disk_size = "20Gi"
    auto_delete = true
  }
  validation {
    condition     = coalesce(var.agent_vms.cpu, 2) >= 2
    error_message = "Cluster must have at least two cores"
  }
  validation {
    condition     = var.agent_vms.memory == null || can(regex("^\\d+(Gi|Mi)$", var.agent_vms.memory))
    error_message = "Cluster must have at least 2Gi"
  }
  validation {
    condition     = var.agent_vms.disk_size == null || can(regex("^\\d+(Gi|Mi)$", var.agent_vms.disk_size))
    error_message = "Nodes must have at least 20Gi"
  }
}

variable "efi" {
  description = "Enable EFI on the nodes"
  type        = bool
  default     = true
}

variable "ssh_user" {
  description = "User for SSH Login"
  type        = string
  default     = "rancher"
}

variable "ssh_keys" {
  description = "The SSH keys to connect to the VMs"
  type        = map(any)
  default     = {}
}
variable "ssh_key_location" {
  description = "The SSH keys to connect to the VMs"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "registration_url" {
  description = "The curl command used to hook up the VMs"
  type        = string
}
