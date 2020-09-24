output "vpc_arn" {
  value       = aws_vpc.main.arn
  description = "VPC_ARN"
}

output "public_subnet_id" {
  value       = aws_subnet.public[*].id
  description = "Public Subnet ID"
}

output "private_subnet_id" {
  value       = aws_subnet.private[*].id
  description = "Private Subnet ID"
}

output "instance_public_ip_addr" {
  value       = aws_instance.webserver[*].public_ip
  description = "Instance Public IP Address"
}

output "instance_public_dns" {
  value       = aws_instance.webserver[*].public_dns
  description = "Instance Public DNS"
}