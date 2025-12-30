# Input Variables – EC2 & Infrastructure Configuration
# Defines all input parameters required for EC2 instance creation, networking, security, IAM, spot instance options, disk sizing, monitoring,
# environment settings, and integration with Route53 and Vault.


variable "ami" {}
variable "instance_type" {}
variable "name" {}
variable "env" {
  default = null
}
variable "zone_id" {}
variable "token" {}
variable "disk_size" {
  default = 20
}

variable "is_tool" {
  default = false
}

variable "iam_policy" {
  default = []
}

variable "spot" {
  default = false
}

variable "monitor" {
  default = false
}
variable "spot_max_price" {
  default = 0
}

variable "subnet" {
  default = null
}

variable "vpc_id" {}
variable "bastion_nodes" {}
variable "app_port" {}
variable "app_cidrs" {}
variable "kms_arn_id" {}