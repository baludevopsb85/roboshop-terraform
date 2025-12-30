# --------------------------------------------------------------------
# DNS Hosted Zone Configuration
# --------------------------------------------------------------------
# To attach EC2 instances and services to the correct Route53 DNS zone

variable "zone_id" {
  default = "Z09055292Q5WKIF45FE2E"
}

# -----------------------------------------------------------------------------
# Base AMI for All EC2 Instances
# -----------------------------------------------------------------------------
# Defines the Amazon Machine Image used to launch all tool servers consistently

variable "ami" {
  default = "ami-09c813fb71547fc4f"
}

# -------------------------------------------------------------------------------------------
# DevOps Tool Servers Configuration
# -------------------------------------------------------------------------------------------
# Controls EC2 instances used for DevOps tooling such as GitHub Actions runners and ELK stack

variable "tools" {
  default = {
    #     vault = {
    #       instance_type = "t3.small"
    #     }
    github-runner = {
      instance_type = "t3.small"
      iam_policy    = ["*"]
      disk_size     = 50
    }
    elk = {
      instance_type = "t3.xlarge"
      spot          = true
    }
  }
}


# ---------------------------------------------------------------------------------
# Runtime Authentication Token
# ---------------------------------------------------------------------------------
# To securely pass sensitive tokens (e.g., GitHub, Vault, or API tokens) at runtime

variable "token" {}

# ------------------------------------------------------------------------------
# Amazon ECR Repositories for Application Images
# ------------------------------------------------------------------------------
# Defines Docker image repositories for Roboshop microservices and CI/CD runners

variable "ecr" {
  default = {
    frontend  = "IMMUTABLE"
    cart      = "IMMUTABLE"
    catalogue = "IMMUTABLE"
    user      = "IMMUTABLE"
    shipping  = "IMMUTABLE"
    payment   = "IMMUTABLE"
    runner    = "MUTABLE"
  }
}
