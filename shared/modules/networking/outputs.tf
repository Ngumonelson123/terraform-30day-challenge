# modules/networking/outputs.tf
# DAY 8: Modules expose values through outputs.
# The root module accesses these as: module.networking.vpc_id

output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = [for s in aws_subnet.private : s.id]
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}
