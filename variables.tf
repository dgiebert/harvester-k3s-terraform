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
  type        = map(any)
  default = {
    number    = 3
    cpu       = 2
    memory    = "4Gi"
    disk_size = "20Gi"
  }
  validation {
    condition     = var.server_vms.number > 0
    error_message = "Cluster must have at least one node"
  }
  validation {
    condition     = var.server_vms.number % 2 == 1
    error_message = "Cluster must have an uneven number of server nodes"
  }
  validation {
    condition     = var.server_vms.cpu >= 2
    error_message = "Cluster must have at least two cores"
  }
  validation {
    condition     = can(regex("^\\d+(Gi|Mi)$", var.server_vms.memory))
    error_message = "Cluster must have at least 2Gi"
  }
  validation {
    condition     = can(regex("^\\d+(Gi|Mi)$", var.server_vms.disk_size))
    error_message = "Nodes must have at least 20Gi"
  }
}

variable "agent_vms" {
  description = "Configuration for the agent nodes "
  type        = map(any)
  default = {
    number    = 0
    cpu       = 2
    memory    = "4Gi"
    disk_size = "20Gi"
  }
  validation {
    condition     = var.agent_vms.cpu >= 2
    error_message = "Cluster must have at least two cores"
  }
  validation {
    condition     = can(regex("^\\d+(Gi|Mi)$", var.agent_vms.memory))
    error_message = "Cluster must have at least 2Gi"
  }
  validation {
    condition     = can(regex("^\\d+(Gi|Mi)$", var.agent_vms.disk_size))
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
  default = { }
}
variable "ssh_key_location" {
  description = "The SSH keys to connect to the VMs"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "rancher2" {
  description = "User for SSH Login"
  type        = map(string)
  default = {
    access_key   = ""
    secret_key   = ""
    url          = ""
  }
  validation {
    condition     = length(var.rancher2.access_key) > 0
    error_message = "Access Key must be provided check https://docs.ranchermanager.rancher.io/reference-guides/user-settings/api-keys"
  }
  validation {
    condition     = length(var.rancher2.secret_key) > 0
    error_message = "Secret Key must be provided check https://docs.ranchermanager.rancher.io/reference-guides/user-settings/api-keys"
  }
  validation {
    condition     = length(var.rancher2.url) > 0
    error_message = "Rancher URL must be provided"
  }
}

variable "cluster" {
  description = "User for SSH Login"
  type        = map(string)
  default = {
    name = "staging"
    k3s_version  = "v1.24.4+k3s1"
    server_args  = "--etcd --controlplane --worker --label 'cattle.io/os=linux'"
    agent_args  = "--worker --label 'cattle.io/os=linux'"
  }
}
