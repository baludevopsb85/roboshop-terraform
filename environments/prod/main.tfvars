# ---------------------------
# EC2 Instances Configuration
# ---------------------------
# Defines the compute instances for applications and tools, including instance type, disk size, and environment-specific settings
# Example: frontend, mysql, mongodb, redis, rabbitmq, cart, catalogue, user, shipping, payment

instances = {
  frontend = {
    instance_type = "t3.small"
  }
  mysql = {
    instance_type = "t3.small"
  }
  mongodb = {
    instance_type = "t3.small"
  }
  redis = {
    instance_type = "t3.small"
  }
  rabbitmq = {
    instance_type = "t3.small"
  }
  cart = {
    instance_type = "t3.small"
  }
  catalogue = {
    instance_type = "t3.small"
  }
  user = {
    instance_type = "t3.small"
  }
  shipping = {
    instance_type = "t3.small"
  }
  payment = {
    instance_type = "t3.small"
  }
}


# --------------------------
# Environment & AMI Settings
# --------------------------
# Global settings for environment, AMI ID, zone, and KMS ARN
# Variables: env, ami, zone_id, zone_name

env       = "prod"
ami       = "ami-0d4983d93b76c67c3"
zone_id   = "Z09055292Q5WKIF45FE2E"
zone_name = "roboshop.store"
