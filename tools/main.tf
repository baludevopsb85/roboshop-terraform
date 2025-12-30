# -------------------------------------------------------------
# EC2 Tool Servers Provisioning (Reusable Module EC2)
# -------------------------------------------------------------
# Creates and manages multiple EC2 instances for DevOps tools :
# (like Vault, ELK, JFROG, GitHub Actions Runner,)
# using a single reusable Terraform
# module, with per-tool customization

module "tools" {
  for_each       = var.tools
  source         = "../modules/ec2"
  ami            = var.ami
  instance_type  = each.value["instance_type"]
  name           = each.key
  zone_id        = var.zone_id
  token          = var.token
  is_tool        = true
  iam_policy     = try(each.value["iam_policy"], [])
  disk_size      = try(each.value["disk_size"], 20)
  spot           = try(each.value["spot"], false)
  monitor        = try(each.value["monitor"], false)
  spot_max_price = try(each.value["spot_max_price"], 0)
  subnet         = try(each.value["subnet"], null)
}

# --------------------------------------------------------------------
# Amazon ECR Repositories for Application Images
# --------------------------------------------------------------------
# Creates multiple Amazon ECR repositories to store Docker images for
# Roboshop microservices with configurable tag mutability

resource "aws_ecr_repository" "main" {
  for_each             = var.ecr
  name                 = each.key
  image_tag_mutability = each.value
}
