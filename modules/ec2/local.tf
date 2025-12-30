# --------------------------------------------------
# Local IAM Policy List (Base + Custom Permissions)
# --------------------------------------------------
# Combines a mandatory base permission (sts:GetCallerIdentity) with user-defined IAM permissions for EC2 instances,
# creating a single list of effective actions the instance can perform.

locals {
  iam_policy = concat(["sts:GetCallerIdentity"], var.iam_policy)
}