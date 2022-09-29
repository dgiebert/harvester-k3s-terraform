terraform {
  required_providers {
    harvester = {
      source  = "harvester/harvester"
      version = "0.5.2"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.24.1"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.2.1"
    }
  }

  required_version = "~> 1.3"
}

provider "rancher2" {
  api_url    = var.rancher2.url
  access_key = var.rancher2.access_key
  secret_key = var.rancher2.secret_key
}
provider "harvester" {
  kubeconfig = var.harvester_kube_config
}
provider "ssh" {
  debug_log = "${path.root}/ssh.log"
}