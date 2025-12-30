# AWS Provider (provider "aws")
# Configures AWS region for resource provisioning (us-east-1)

provider "aws" {
  region = "us-east-1"
}


# Terraform Backend (terraform { backend "s3" })
# Configures S3 as the remote backend to store Terraform state files

terraform {
  backend "s3" {}
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.17.0"
    }
  }
}


# Vault Provider (provider "vault")
# Connects Terraform to HashiCorp Vault for secrets management.
# Uses var.token for authentication.

provider "vault" {
  address = "http://vault-internal.robobal.store:8200"
  token   = var.token
}


# Helm Provider (provider "helm")
# Connects Terraform to Kubernetes via Helm
# Uses local kubeconfig (~/.kube/config) for cluster access

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}