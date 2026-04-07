# Creating AWS-EKS-Cluster
resource "aws_eks_cluster" "main" {
  name     = var.env
  role_arn = aws_iam_role.cluster.arn
  version  = var.eks_version
  vpc_config {
    subnet_ids = var.subnet_ids
  }
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
}


resource "aws_launch_template" "main" {
  for_each = var.node_groups
  name     = each.key

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 20
      encrypted   = true
      kms_key_id  = var.kms_arn_id
    }
  }

}


# Creating aws-eks-node-group
resource "aws_eks_node_group" "main" {
  for_each        = var.node_groups
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids
  capacity_type   = each.value["capacity_type"]
  instance_types  = each.value["instance_types"]

  launch_template {
    name    = aws_launch_template.main[each.key].name
    version = "$Latest"
  }

  scaling_config {
    desired_size = each.value["min_nodes"]
    max_size     = each.value["max_nodes"]
    min_size     = each.value["min_nodes"]
  }

  update_config {
    max_unavailable = 1
  }
}


# Enable VPC CNI add-on for Pod NetworkPolicy in EKS
resource "aws_eks_addon" "main" {
  for_each             = var.addons
  cluster_name         = aws_eks_cluster.main.name
  addon_name           = each.key
  configuration_values = jsonencode(each.value["config"])
}


resource "aws_eks_access_entry" "access" {
  for_each          = var.access
  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = each.value["principal_arn"]
  kubernetes_groups = try(each.value["kubernetes_groups"], [])
  type              = "STANDARD"
}


resource "aws_eks_access_policy_association" "main" {
  for_each      = var.access
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = each.value["policy_arn"]
  principal_arn = each.value["principal_arn"]

  access_scope {
    type       = each.value["access_scope"]
    namespaces = each.value["access_scope"] == "cluster" ? [] : try(each.value["namespaces"], [])
  }
}



