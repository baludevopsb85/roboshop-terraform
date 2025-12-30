# EC2 Instances Configuration
# Defines the compute instances for applications and tools, including instance type, disk size, and environment-specific settings
# Example: frontend, mysql, mongodb, redis, rabbitmq, cart, catalogue, user, shipping, payment

# instances = {
#   frontend = {
#     instance_type = "t3.small"
#     disk_size     = 30
#   }
#   mysql = {
#     instance_type = "t3.small"
#     disk_size     = 20
#   }
#   mongodb = {
#     instance_type = "t3.small"
#     disk_size     = 20
#   }
#   redis = {
#     instance_type = "t3.small"
#     disk_size     = 20
#   }
#   rabbitmq = {
#     instance_type = "t3.small"
#     disk_size     = 20
#   }
#   cart = {
#     instance_type = "t3.small"
#     disk_size     = 30
#   }
#   catalogue = {
#     instance_type = "t3.small"
#     disk_size     = 30
#   }
#   user = {
#     instance_type = "t3.small"
#     disk_size     = 30
#   }
#   shipping = {
#     instance_type = "t3.small"
#     disk_size     = 30
#   }
#   payment = {
#     instance_type = "t3.small"
#     disk_size     = 30
#   }
# }


# Databases Configuration
# Specifies database instances with instance type, disk size, subnet reference, application port, and allowed CIDRs
# Example: mysql, mongodb, redis, rabbitmq

databases = {
  mysql = {
    instance_type = "t3.small"
    disk_size     = 20
    subnet_ref    = "db-az1"
    app_port      = 3306
    app_cidrs     = ["10.10.10.0/24", "10.10.11.0/24"]
  }
  mongodb = {
    instance_type = "t3.small"
    disk_size     = 20
    subnet_ref    = "db-az1"
    app_port      = 27017
    app_cidrs     = ["10.10.10.0/24", "10.10.11.0/24"]
  }
  redis = {
    instance_type = "t3.small"
    disk_size     = 20
    subnet_ref    = "db-az2"
    app_port      = 6379
    app_cidrs     = ["10.10.10.0/24", "10.10.11.0/24"]
  }
  rabbitmq = {
    instance_type = "t3.small"
    disk_size     = 20
    subnet_ref    = "db-az2"
    app_port      = 5672
    app_cidrs     = ["10.10.10.0/24", "10.10.11.0/24"]
  }
}


# Environment & AMI Settings
# Global settings for environment, AMI ID, zone, and KMS ARN
# Variables: env, ami, zone_id, zone_name, kms_arn_id

env        = "dev"
ami        = "ami-0051178e229f92cb4"
zone_id    = "Z09055292Q5WKIF45FE2E"
zone_name  = "rdevopsb85.online"
kms_arn_id = "arn:aws:kms:us-east-1:739561048503:key/13b65efd-dc45-4824-8a8a-b618dfda88d9"


# EKS Cluster Configuration
# Defines EKS cluster version, node groups (spot/on-demand), access permissions for roles, and cluster addons
# Example: main cluster, node_groups, access, addons

eks = {
  main = {
    eks_version = 1.33
    #subnet_ids  = ["subnet-05f2d527e96f275c9", "subnet-0506db159acceacf5"]
    node_groups = {
      spot1 = {
        min_nodes      = 1
        max_nodes      = 10
        instance_types = ["t3.xlarge"]
        capacity_type  = "SPOT"
      }
      #       one = {
      #         min_nodes       = 2
      #         max_nodes       = 10
      #         instance_types  = ["t3.medium"]
      #         capacity_type   = "ON_DEMAND"
      #       }
    }
    access = {
      workstation = {
        principal_arn = "arn:aws:iam::739561048503:role/workstation-role"
        access_scope  = "cluster"
        policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      }
      github-runner = {
        principal_arn = "arn:aws:iam::739561048503:role/github-runner-ec2-role"
        access_scope  = "cluster"
        policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      }
    }
    addons = {
      vpc-cni = {
        config = {
          "enableNetworkPolicy" : "true",
          "nodeAgent" : {
            "enablePolicyEventLogs" : "true"
          }
        }
      }

      eks-pod-identity-agent = {
        config = {}
      }

    }
  }
}


# VPC & Networking Configuration
# VPC CIDR, subnet CIDRs, availability zones, IGW/NGW setup, and VPC peering
# Example: vpc.main, subnets, vpc_peers

vpc = {
  main = {
    vpc_cidr_block = "10.10.0.0/16"
    subnets = {
      app-az1 = {
        cidr_block        = "10.10.10.0/24"
        availability_zone = "us-east-1a"
        ngw               = true
      }
      app-az2 = {
        cidr_block        = "10.10.11.0/24"
        availability_zone = "us-east-1b"
        ngw               = true
      }
      db-az1 = {
        cidr_block        = "10.10.12.0/24"
        availability_zone = "us-east-1a"
        ngw               = true
      }
      db-az2 = {
        cidr_block        = "10.10.13.0/24"
        availability_zone = "us-east-1b"
        ngw               = true
      }
      gateway = {
        cidr_block        = "10.10.0.0/24"
        availability_zone = "us-east-1a"
        igw               = true
      }
      lb-az1 = {
        cidr_block        = "10.10.14.0/24"
        availability_zone = "us-east-1a"
        ngw               = true
      }
      lb-az2 = {
        cidr_block        = "10.10.15.0/24"
        availability_zone = "us-east-1b"
        ngw               = true
      }
      public-az1 = {
        cidr_block        = "10.10.16.0/24"
        availability_zone = "us-east-1a"
        igw               = true
      }
      public-az2 = {
        cidr_block        = "10.10.17.0/24"
        availability_zone = "us-east-1b"
        igw               = true
      }
    }
    vpc_peers = {
      "vpc-06ac3dd6a7a23a33a" = {
        name        = "default"
        vpc_id      = "vpc-06ac3dd6a7a23a33a"
        vpc_cidr    = "172.31.0.0/16"
        route_table = "rtb-00e8a453486ad1e90"
      }
    }
  }
}


# Bastion Nodes / SSH Access
# List of IPs allowed to access the infrastructure via bastion for management or administrative purposes
# Variable: bastion_nodes

bastion_nodes = ["172.31.20.239/32", "172.31.47.213/32"]