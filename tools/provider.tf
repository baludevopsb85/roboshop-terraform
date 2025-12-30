# AWS Provider Configuration
# Defines AWS as the cloud provider and sets the region where all resources will be created.

provider "aws" {
  region = "us-east-1"
}


# Remote Terraform State Configuration (S3 Backend)
# Stores Terraform state remotely in S3 so teams can collaborate safely and avoid state conflicts

terraform {
  backend "s3" {
    bucket = "terraform-b85"
    key    = "tools/terraform.tfstate"
    region = "us-east-1"
  }
}


# HashiCorp Vault Provider Configuration
# Connects Terraform to Vault to securely fetch secrets instead of hardcoding credentials

provider "vault" {
  address = "http://vault-internal.robobal.store:8200"
  token   = var.token
}
