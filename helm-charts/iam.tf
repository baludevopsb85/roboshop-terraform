# Roles for External DNS
resource "aws_iam_role" "external-dns" {
  name = "${var.env}-pod-external-dns-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "external-dns"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = ["route53:*"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}


resource "aws_eks_pod_identity_association" "external-dns" {
  cluster_name    = var.env
  namespace       = "tools"
  role_arn        = "external-dns"
  service_account = aws_iam_role.external-dns.arn
}


## Prometheus EC2 Discovery
resource "aws_iam_role" "prometheus-server" {
  name = "${var.env}-pod-prometheus-server-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "prometheus-server"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ec2:DescribeInstances",
            "ec2:DescribeInstanceStatus"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

}

resource "aws_eks_pod_identity_association" "prometheus-server" {
  cluster_name    = var.env
  namespace       = "tools"
  service_account = "kube-prometheus-stack-prometheus"
  role_arn        = aws_iam_role.prometheus-server.arn
}


## Cluster Autoscaler
resource "aws_iam_role" "cluster-autoscaler" {
  name = "${var.env}-cluster-autoscaler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "cluster-autoscaler"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeScalingActivities",
            "ec2:DescribeImages",
            "ec2:DescribeInstanceTypes",
            "ec2:DescribeLaunchTemplateVersions",
            "ec2:GetInstanceTypesFromInstanceRequirements",
            "eks:DescribeNodegroup",
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

}

resource "aws_eks_pod_identity_association" "cluster-autoscaler" {
  cluster_name    = var.env
  namespace       = "tools"
  service_account = "cluster-autoscaler-aws-cluster-autoscaler"
  role_arn        = aws_iam_role.cluster-autoscaler.arn
}



















