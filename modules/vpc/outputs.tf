output "subnets" {
  value = aws_subnet.main
}

output "vpc_id" {
  value = aws_vpc.main.id
}