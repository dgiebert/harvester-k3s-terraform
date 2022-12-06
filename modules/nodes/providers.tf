terraform {
  required_providers {
    harvester = {
      source  = "harvester/harvester"
      version = "0.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.0"
    }
  }
  required_version = "~> 1.3"
}