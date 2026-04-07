provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {}
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.17.0"
    }
  }
}

provider "vault" {
  address = "http://vault-internal.robobal.store:8200"
  token   = var.token
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}


