# Harvester + k3s Provisioner using Rancher

<!-- BEGIN_TF_DOCS -->
## Usage

1. Get the Harvester kubeconfig and place it in `harvester.kubeconfig`
2. Create the API Keys [docs](https://docs.ranchermanager.rancher.io/reference-guides/user-settings/api-keys)
    ![](/docs/rancher.png)
2. Create the SSH Keys
    ![](/docs/ssh-keys.png)
3. Create the Cluster with `terraform apply`

```hcl
terraform {
  required_version = ">= 0.14"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.8.1"
    }
  }
}

provider "vault" {
  address = <VAULT_URL>
  token   = <VAULT_TOKEN>
}

data "vault_generic_secret" "rancher" {
  path = <VAULT_PATH>/rancher"
}
data "vault_generic_secret" "ssh-keys" {
  path = <VAULT_PATH>/ssh-keys"
}

module "harvester-k3s" {
  source   = "git::github.com/dgiebert/harvester-k3s-terraform?ref=v0.1.0"
  rancher2 = data.vault_generic_secret.rancher.data
  ssh_keys = data.vault_generic_secret.ssh-keys.data
  cluster  = {
    labels = { environment = "staging" }
  }
  server_vms = {
    number    = 1
    cpu       = 2
    memory    = "4Gi"
    disk_size = "10Gi"
  }
  agent_vms = {
    number    = 0
    cpu       = 2
    memory    = "4Gi"
    disk_size = "10Gi"
  }
}
```

#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.3 |
| <a name="requirement_harvester"></a> [harvester](#requirement_harvester) | 0.6.0 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_agent_vms"></a> [agent_vms](#input_agent_vms) | Configuration for the agent nodes | <pre>object({<br>    number      = optional(number)<br>    cpu         = optional(number)<br>    memory      = optional(string)<br>    disk_size   = optional(string)<br>    auto_delete = optional(bool)<br>  })</pre> |
| <a name="input_cluster"></a> [cluster](#input_cluster) | User for SSH Login | `any` |
| <a name="input_cluster_vlan"></a> [cluster_vlan](#input_cluster_vlan) | Name of the Cluster VLAN | `string` |
| <a name="input_domain"></a> [domain](#input_domain) | domain for VM | `string` |
| <a name="input_efi"></a> [efi](#input_efi) | Enable EFI on the nodes | `bool` |
| <a name="input_harvester_kube_config"></a> [harvester_kube_config](#input_harvester_kube_config) | The location to check for the kubeconfig to connect to Harverster | `string` |
| <a name="input_namespace"></a> [namespace](#input_namespace) | The namespace resources get deployed to within Harvester | `string` |
| <a name="input_rancher2"></a> [rancher2](#input_rancher2) | User for SSH Login | `map(string)` |
| <a name="input_server_vms"></a> [server_vms](#input_server_vms) | Configuration for the server nodes | <pre>object({<br>    number      = optional(number)<br>    cpu         = optional(number)<br>    memory      = optional(string)<br>    disk_size   = optional(string)<br>    auto_delete = optional(bool)<br>  })</pre> |
| <a name="input_ssh_keys"></a> [ssh_keys](#input_ssh_keys) | The SSH keys to connect to the VMs | `map(string)` |
| <a name="input_ssh_user"></a> [ssh_user](#input_ssh_user) | User for SSH Login | `string` |
| <a name="input_vlan_id"></a> [vlan_id](#input_vlan_id) | The VLAN ID used to connect the VMs | `number` |
| <a name="input_vlan_name"></a> [vlan_name](#input_vlan_name) | The VLAN name used to connect the VMs | `string` |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_clusterInfo"></a> [clusterInfo](#output_clusterInfo) | Combined output to be used with other providers/modules |
| <a name="output_ips"></a> [ips](#output_ips) | The URL used to provision new nodes |
| <a name="output_virtual_machines"></a> [virtual_machines](#output_virtual_machines) | The provisioned virtual machines on harvester. (https://registry.terraform.io/providers/harvester/harvester/latest/docs/data-sources/virtualmachine) |
<!-- END_TF_DOCS -->