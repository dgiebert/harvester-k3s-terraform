terraform {
  required_providers {
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