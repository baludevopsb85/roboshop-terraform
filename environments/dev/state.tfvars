# Terraform Backend Configuration
# Specifies where Terraform stores its state remotely.
# bucket: S3 bucket name to hold the state file.
# key: Path within the bucket for this environment’s state file.
# region: AWS region where the S3 bucket resides.

bucket = "terraform-b85"
key    = "roboshop-terraform/dev/terraform.tfstate"
region = "us-east-1"
