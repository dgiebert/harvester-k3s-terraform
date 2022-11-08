terraform {
  required_providers {
    harvester = {
      source  = "harvester/harvester"
      version = "0.6.0"
    }
  }
  required_version = "~> 1.3"
}

provider "harvester" {
  kubeconfig = var.harvester_kube_config
}