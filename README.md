# Harvester + k3s Provisioner using Rancher

## Variables

| Name                  | Default                                                                                   | Description                                                                   |
|:----------------------|:------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------|
| namespace             | harvester-public                                                                          | The namespace resources get deployed to within Harvester                      |
| vlan_id               | 2                                                                                         | The VLAN ID used to connect the VMs                                           |
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

| Name      | Default | Description                       |
|:----------|:--------|:----------------------------------|
| number    | 3       | The number of nodes to be created |
| cpu       | 2       | The number of CPUs                |
| memory    | 4Gi     | The amount of memory              |
| disk_size | 20Gi    | The disk size                     |

The `agent_vms` are not deployed per default (number = 0)

## Usage

1. Get the Harvester kubeconfig and place it in `harvester.kubeconfig`
2. Create a file called `terraform.tfvars` and define the needed variables
    ```
    rancher2 = {
        access_key   = "<ACCESS_KEY>"
        secret_key   = "<SECRET_KEY>"
        url          = "<RANCHER_URL>"
    }

    ssh_keys = {
        user = "ssh-rsa AAAAB3Nz[...]"
    }
    ```
3. Create the server using a target: `terraform apply -target=harvester_virtualmachine.agents`
4. Create the Cluster with `terraform apply`

### Module

1. Get the Harvester kubeconfig and place it in `harvester.kubeconfig`
2. Create the server using a target: `terraform apply -target=module.harvester-k3s.harvester_virtualmachine.agents`
3. Create the Cluster with `terraform apply`

```
module "harvester-k3s" {
  source = "git::github.com/dgiebert/harvester-k3s-terraform?ref=v0.0.1"

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
