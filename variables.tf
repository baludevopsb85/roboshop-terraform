# -------------------------------------------------------------------------
# Terraform Input Variables
# -------------------------------------------------------------------------
# This section defines all input variables required for provisioning
# AWS infrastructure, EKS clusters, VPCs, databases, and related resources.
# Users can override these variables per environment.

variable "ami" {}
variable "databases" {}
variable "env" {}
variable "zone_id" {}
variable "zone_name" {}
variable "token" {}
variable "eks" {}
variable "vpc" {}
variable "bastion_nodes" {}
variable "kms_arn_id" {}
