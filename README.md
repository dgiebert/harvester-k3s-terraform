# Harvester + k3s Provisioner using Rancher

## Variables

| Name                  | Default                                                                                   | Description                                                                   |
|:----------------------|:------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------|
| namespace             | harvester-public                                                                          | The namespace resources get deployed to within Harvester                      |
| vlan_id               | 2                                                                                         | The VLAN ID used to connect the VMs                                           |
| vlan_name             | ""                                                                                        | Set this if you want to import a network                                      |
| efi                   | true                                                                                      | Enable EFI on the nodes                                                       |
| ssh_user              | rancher                                                                                   | User for the SSH Login                                                        |
| ssh_keys              | None                                                                                      | e.g. { username = "ssh-rsa AAAAB3Nz[...]" }                                   |
| ssh_key_location      | ~/.ssh/id_rsa                                                                             | SSH Key to connect to the hosts                                               |
| harvester_kube_config | ./harvester.kubeconfig                                                                    | The location to check for the kubeconfig to connect to Harverster             |
| ssh_debug_log         | ""                                                                                        | Enable debug logs for the SSH commands (pass in a file name e.g. './ssh.log') |
| rancher2              | [see below](https://github.com/dgiebert/harvester-k3s-terraform#rancher2)                 | Configuration for the rancher management server                               |
| cluster               | [see below](https://github.com/dgiebert/harvester-k3s-terraform#cluster)                  | Configuration for created k3s cluster                                         |
| server_vms            | [see below](https://github.com/dgiebert/harvester-k3s-terraform#server_vms-and-agent_vms) | Configuration for the server nodes                                            |
| agent_vms             | [see below](https://github.com/dgiebert/harvester-k3s-terraform#server_vms-and-agent_vms) | Configuration for the agent nodes                                             |

#### rancher2

| Name       | Default | Description                                                                                                                  |
|:-----------|:--------|:-----------------------------------------------------------------------------------------------------------------------------|
| access_key | ""      | Create a access key in the Rancher UI [docs](https://docs.ranchermanager.rancher.io/reference-guides/user-settings/api-keys) |
| secret_key | ""      | Create a secret key in the Rancher UI [docs](https://docs.ranchermanager.rancher.io/reference-guides/user-settings/api-keys) |
| url        | ""      | Rancher HTTPS endpoint                                                                                                       |

#### cluster

| Name        | Default                                                       | Description                                     |
|:------------|:--------------------------------------------------------------|:------------------------------------------------|
| name        | "staging"                                                     | The name for the cluster                        |
| k3s_version | "v1.24.4+k3s1"                                                | The k3s version to be deployed                  |
| server_args | "--etcd --controlplane --worker --label 'cattle.io/os=linux'" | The k3s server args passed to the agent install |
| agent_args  | "--worker --label 'cattle.io/os=linux'"                       | The k3s agent args passed to the agent install  |

#### server_vms and agent_vms

| Name        | Default | Description                             |
|:------------|:--------|:----------------------------------------|
| number      | 3       | The number of nodes to be created       |
| cpu         | 4       | The number of CPUs                      |
| memory      | 16Gi    | The amount of memory                    |
| disk_size   | 20Gi    | The disk size                           |
| auto_delete | true    | Delete the root partition automatically |

The `agent_vms` are not deployed per default (number = 0)

## Outputs

| Name             | Default | Description                                                                                                                                                |
|:-----------------|:--------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| virtual_machines |         | The provisioned virtual machines on harvester. [docs](https://registry.terraform.io/providers/harvester/harvester/latest/docs/data-sources/virtualmachine) |
| registration_url | ""      | The URL used to provision new nodes                                                                                                                        |
| ips              | [""]    | The IPs of the nodes                                                                                                                                       |
| cloud_init       | ""      | Cloudinit used to provision the nodes                                                                                                                      |



## Usage

1. Get the Harvester kubeconfig and place it in `harvester.kubeconfig`
2. Create the API Keys [docs](https://docs.ranchermanager.rancher.io/reference-guides/user-settings/api-keys)
3. Create the Cluster with `terraform apply`

```
module "harvester-k3s" {
  source = "git::github.com/dgiebert/harvester-k3s-terraform?ref=v0.1.0"

  rancher2 = {
    access_key   = "<ACCESS_KEY>"
    secret_key   = "<SECRET_KEY>"
    url          = "<RANCHER_URL>"
  }

  ssh_keys = {
    user = "ssh-rsa AAAAB3Nz[...]"
  }
}
```

### Tipps
- `terraform import module.harvester-k3s.module.nodes.harvester_network.vlan namespace/network-name`