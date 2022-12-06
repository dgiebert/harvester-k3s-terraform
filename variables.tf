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

variable "vlan_name" {
  description = "The VLAN name used to connect the VMs"
  type        = string
  default     = ""
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
    number      = 3
    cpu         = 4
    memory      = "16Gi"
    disk_size   = "20Gi"
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
    number      = 0
    cpu         = 2
    memory      = "4Gi"
    disk_size   = "20Gi"
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
  description = "User for SSH to connect to the VMs"
  type        = string
  default     = "rancher"
}

variable "ssh_keys" {
  description = "The SSH keys to connect to the VMs"
  type        = map(string)
  default = {
    user1 = "ssh-rsa AAAAB3Nza"
    user2 = "ssh-rsa AAAAB3Nza"
  }
}

variable "rancher2" {
  description = "Connection details for the Rancher2 API"
  type = object({
    access_key = string,
    secret_key = string,
    url        = string
  })
  default = {
    access_key = ""
    secret_key = ""
    url        = ""
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

variable "cluster_vlan" {
  description = "Name of the Cluster VLAN"
  type        = string
  default     = "cluster-vlan"
}

variable "clusterInfo" {
  description = "Details for the k3s cluster to be created"
  type = object({
    name             = optional(string),
    labels           = optional(map(string)),
    k3s_version      = optional(string),
    server_args      = optional(string),
    agent_args       = optional(string),
    registration_url = optional(string)
  })
  default = {
    name             = "staging"
    labels           = {}
    k3s_version      = "v1.24.8+k3s1"
    server_args      = "--etcd --controlplane --label 'cattle.io/os=linux'"
    agent_args       = "--worker --label 'cattle.io/os=linux'"
    registration_url = ""
  }
}

variable "image_name" {
  description = "Name for the image to be downloaded"
  type        = string
  default     = "opensuse-leap-15.4"
}
variable "download_image" {
  description = "Should the image be downloaded or is already present"
  type        = bool
  default     = true
}
variable "source_image" {
  description = "URL for the image to download"
  type        = string
  default     = "https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.4/images/openSUSE-Leap-15.4.x86_64-NoCloud.qcow2"
}

variable "snapshot_retention" {
  description = "How many snapshots should be kept"
  type        = number
  default     = 5
}

variable "snapshot_schedule_cron" {
  description = "How often should a snapshots be taken (cron format)"
  type        = string
  default     = "0 */5 * * *"
}

variable "s3_credential_config" {
  description = "Check https://registry.terraform.io/providers/rancher/rancher2/latest/docs/resources/cloud_credential#s3_credential_config"
  type = object({
    access_key     = string,
    secret_key     = string,
    default_bucket = string,
    default_region = string,
  })
  default = {
    access_key     = "",
    secret_key     = "",
    default_bucket = "",
    default_region = "",
  }
}
