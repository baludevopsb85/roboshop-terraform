# Fetch Existing AWS Security Group
# Reads an already-created security group from AWS so it can be reused without creating a new one

data "aws_security_group" "allow-all" {
  name = "allow-all"
}


# Retrieve SSH Credentials from HashiCorp Vault
# Securely fetches SSH username and password/key from Vault instead of storing secrets in code

data "vault_generic_secret" "ssh-creds" {
  path = "roboshop-infra/ssh"
}