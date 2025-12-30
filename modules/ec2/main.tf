# ------------------------------------------
# Security Group: TLS and Application Access
# ------------------------------------------
# Defines ingress (SSH & app ports) and egress rules for the EC2 instance with proper tagging

resource "aws_security_group" "allow_tls" {
  name        = local.tagName
  description = local.tagName
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_nodes
  }

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = var.app_cidrs
  }

  tags = {
    Name = local.tagName
  }
}

# -------------------------------
# EC2 Instance: Standard Instance
# -------------------------------
#Creates a regular EC2 instance with specified AMI, instance type, security groups, IAM profile, subnet, and
# encrypted root volume

resource "aws_instance" "instance" {
  count                  = var.spot ? 0 : 1
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  iam_instance_profile   = aws_iam_instance_profile.main.name
  subnet_id              = var.subnet

  root_block_device {
    volume_size = var.disk_size
    encrypted   = true
    kms_key_id  = var.kms_arn_id
  }

  tags = {
    Name    = local.tagName
    monitor = var.monitor
  }
}


# ---------------------------
# EC2 Instance: Spot Instance
# ---------------------------
# Creates a spot EC2 instance with market options and interruption behavior. Uses a different security group and tagging

resource "aws_instance" "spot_instance" {
  count                  = var.spot ? 1 : 0
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.allow-all.id]
  iam_instance_profile   = aws_iam_instance_profile.main.name
  #subnet_id              = var.subnet

  root_block_device {
    volume_size = var.disk_size
  }

  instance_market_options {
    market_type = "spot"
    spot_options {
      #max_price = var.spot_max_price
      instance_interruption_behavior = "stop"
      spot_instance_type             = "persistent"
    }
  }

  tags = {
    Name = local.tagName
  }
}


# ----------------------------------
# DNS Record: Private Route53 Entry
# ----------------------------------
# Creates a private DNS A record pointing to the instance’s private IP (handles spot or regular instance)

resource "aws_route53_record" "record" {
  zone_id = var.zone_id
  name    = local.dnsName
  type    = "A"
  ttl     = 30
  records = var.spot ? [aws_instance.spot_instance[0].private_ip] : [aws_instance.instance[0].private_ip]
}


# --------------------------------
# DNS Record: Public Route53 Entry
# --------------------------------
# Creates a public DNS A record pointing to the instance’s public IP (only if env is null)

resource "aws_route53_record" "public" {
  count   = var.env == null ? 1 : 0
  zone_id = var.zone_id
  name    = local.dnsNamePublic
  type    = "A"
  ttl     = 30
  records = var.spot ? [aws_instance.spot_instance[0].public_ip] : [aws_instance.instance[0].public_ip]
}


# -----------------------
# Ansible Pull Execution
# -----------------------
# Runs ansible-pull on the created instance using SSH credentials from Vault, pulling playbooks from GitHub for
# configuration management

resource "null_resource" "ansible" {

  count = var.env == null ? 0 : 1

  triggers = {
    instance_id = var.spot ? aws_instance.spot_instance[0].id : aws_instance.instance[0].id
  }

  depends_on = [aws_route53_record.record]
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = data.vault_generic_secret.ssh-creds.data["username"]
      password = data.vault_generic_secret.ssh-creds.data["password"]
      host     = var.spot ? aws_instance.spot_instance[0].private_ip : aws_instance.instance[0].private_ip
    }

    inline = [
      "ansible-pull -i localhost, -U https://github.com/baludevopsb85/roboshop-ansible roboshop.yml -e role_name=${var.name} -e token=${var.token} -e env=${var.env} | sudo tee /opt/ansible.log"
    ]
  }
}