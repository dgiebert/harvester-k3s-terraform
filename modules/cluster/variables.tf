variable "cluster_name" {
  description = "Name used for the cluster"
  type        = string
  default     = ""
}
variable "k3s_version" {
  description = "Version used for the cluster"
  type        = string
  default     = ""
}
variable "enable_network_policy" {
  description = "Enable Network Policies?"
  type        = bool
  default     = true
}
variable "labels" {
  description = "Add labels to the cluster"
  type        = map
  default     = {}
}

variable "rancher2" {
  description = "User for SSH Login"
  type        = map(string)
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