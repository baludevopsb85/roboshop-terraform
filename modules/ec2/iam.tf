# ----------------------------------------------------------------------------------------------
# EC2 IAM Role(Permissions for the server)
# ----------------------------------------------------------------------------------------------
# Creates an IAM role that allows an EC2 instance to securely access AWS services (like S3, ECR)
# without using access keys

# Attach Permissions Directly to the EC2 Role using inline_policy
# Grants required AWS permissions to the EC2 instance based on the application or tool needs

resource "aws_iam_role" "main" {
  name = var.is_tool ? "${var.name}-ec2-role" : "${var.name}-${var.env}-ec2-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "inline"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = local.iam_policy
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

# -------------------------------------------------------------------------------------------
# Grants required AWS permissions to the EC2 instance based on the application or tool needs
# -------------------------------------------------------------------------------------------
# Binds the IAM role to the EC2 instance so the server can actually use those permissions

resource "aws_iam_instance_profile" "main" {
  name = var.is_tool ? "${var.name}-ec2-role" : "${var.name}-${var.env}-ec2-role"
  role = aws_iam_role.main.name
}

# ----------------------------------------------
# Enable AWS SSM Access (No SSH Required)
# ----------------------------------------------
# Attaches AWS Systems Manager policy, allowing:
# Session Manager access
# Remote commands
# Patching & monitoring
# without opening SSH ports

resource "aws_iam_role_policy_attachment" "inspector-scanning-attachment" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}