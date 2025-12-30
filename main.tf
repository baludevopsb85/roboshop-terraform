# ------------------------------------------
# VPC Module (module "vpc")
# ------------------------------------------
# Creates VPCs and subnets based on var.vpc.
# Configures CIDR blocks and VPC peering.
# Uses for_each to support multiple VPCs.

module "vpc" {
  source = "./modules/vpc"

  for_each       = var.vpc
  env            = var.env
  subnets        = each.value["subnets"]
  vpc_cidr_block = each.value["vpc_cidr_block"]
  vpc_peers      = each.value["vpc_peers"]
}


# -------------------------------------------------------------------------------------
# EC2 Module (module "ec2")
# -------------------------------------------------------------------------------------
# Launches database EC2 instances (MySQL, MongoDB, Redis, RabbitMQ).
# Assigns AMI, instance type, disk size, subnet, VPC, security, and port configurations.
# Integrates with bastion nodes and KMS for encryption.

module "ec2" {
  for_each      = var.databases
  source        = "./modules/ec2"
  ami           = var.ami
  env           = var.env
  instance_type = each.value["instance_type"]
  disk_size     = each.value["disk_size"]
  name          = each.key
  zone_id       = var.zone_id
  token         = var.token
  subnet        = lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), each.value["subnet_ref"], null), "id", null)
  vpc_id        = lookup(lookup(module.vpc, "main", null), "vpc_id", null)
  bastion_nodes = var.bastion_nodes
  app_cidrs     = each.value["app_cidrs"]
  app_port      = each.value["app_port"]
  kms_arn_id    = var.kms_arn_id
}

# ----------------------------------------------------
# EKS Module (module "eks")
# ----------------------------------------------------
# Deploys EKS clusters with node groups
# Configures subnets, access roles, and cluster addons
# Supports Vault integration and KMS encryption

module "eks" {
  for_each    = var.eks
  source      = "./modules/eks"
  env         = var.env
  eks_version = each.value["eks_version"]
  subnet_ids  = [lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), "app-az1", null), "id", null),lookup(lookup(lookup(lookup(module.vpc, "main", null), "subnets", null), "app-az2", null), "id", null)]
  node_groups = each.value["node_groups"]
  access      = each.value["access"]
  addons      = each.value["addons"]
  vault_token = var.token
  kms_arn_id  = var.kms_arn_id
}

# -----------------------------------------------------------------------
# Output (output "main")
# -----------------------------------------------------------------------
# Exposes the VPC module output for reference in other modules or scripts

output "main" {
  value = module.vpc
}