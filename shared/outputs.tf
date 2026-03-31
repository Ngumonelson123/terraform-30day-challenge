# =============================================================================
# outputs.tf
# DAY 4: Outputs expose values from your infrastructure so you (or other
#        modules) can use them without looking inside the state file.
#
# DAY 15 DEMO POINT: The ALB DNS name output from the compute module flows
#        directly into the Cloudflare record in main.tf. You can see this
#        chain: AWS API → state → output → cloudflare_record.app.value
# =============================================================================

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
output "vpc_id" {
  description = "ID of the VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = module.networking.private_subnet_ids
}

# -----------------------------------------------------------------------------
# Compute
# -----------------------------------------------------------------------------
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer. Use this to test the app."
  value       = module.compute.alb_dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the ALB (needed for Route53 alias records)."
  value       = module.compute.alb_zone_id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group."
  value       = module.compute.asg_name
}

# -----------------------------------------------------------------------------
# Bastion (DAY 11: output is null when bastion is disabled)
# -----------------------------------------------------------------------------
output "bastion_public_ip" {
  description = "Public IP of the bastion host. Empty string when disabled."
  value       = local.bastion_count > 0 ? aws_instance.bastion[0].public_ip : ""
}

# -----------------------------------------------------------------------------
# Database (DAY 13: endpoint exposed but password is NOT output — it's sensitive)
# -----------------------------------------------------------------------------
output "db_endpoint" {
  description = "RDS endpoint. Empty string when RDS is disabled."
  value       = local.rds_count > 0 ? module.database[0].db_endpoint : ""
}

# DO NOT add an output for db_password — even with sensitive = true,
# it still ends up in state in plaintext. Read it from SSM when needed.

# -----------------------------------------------------------------------------
# Meta
# -----------------------------------------------------------------------------
output "workspace" {
  description = "Current Terraform workspace."
  value       = terraform.workspace
}

output "environment" {
  description = "Deployed environment tag."
  value       = var.environment
}
