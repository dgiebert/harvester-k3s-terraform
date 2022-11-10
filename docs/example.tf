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
  address = "<VAULT_URL>"
  token   = "<VAULT_TOKEN>"
}

data "vault_generic_secret" "rancher" {
  path = "<VAULT_PATH>/rancher"
}
data "vault_generic_secret" "ssh-keys" {
  path = "<VAULT_PATH>/ssh-keys"
}

module "harvester-k3s" {
  source   = "git::github.com/dgiebert/harvester-k3s-terraform?ref=v0.2.0"
  rancher2 = data.vault_generic_secret.rancher.data
  ssh_keys = data.vault_generic_secret.ssh-keys.data
  cluster = {
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
