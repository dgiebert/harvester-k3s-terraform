terraform {
  required_providers {
    harvester = {
      source  = "harvester/harvester"
      version = "0.6.0"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.24.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.0"
    }
  }
  required_version = "~> 1.3"
}

provider "harvester" {
  kubeconfig = local.harvester_kube_config
}

provider "rancher2" {
  api_url    = var.rancher2.url
  access_key = var.rancher2.access_key
  secret_key = var.rancher2.secret_key
}

provider "kubernetes" {
  config_path = local.harvester_kube_config
}