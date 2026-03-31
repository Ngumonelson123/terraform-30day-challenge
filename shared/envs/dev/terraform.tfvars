# =============================================================================
# envs/dev/terraform.tfvars
# DAY 7: File layout alternative to workspaces.
#        Use with: terraform apply -var-file="envs/dev/terraform.tfvars"
#
# Dev is cheap — minimal instances, no NAT, no RDS, bastion on.
# =============================================================================

project     = "tfc"
environment = "dev"
aws_region  = "us-east-1"

vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

ami_id               = "ami-0c02fb55956c7d316"
instance_type        = "t3.micro"
asg_min_size         = 1
asg_max_size         = 2
asg_desired_capacity = 1

enable_bastion        = true
enable_rds            = false
enable_nat_gateway    = false
enable_datadog        = false
enable_cloudflare_dns = false

common_tags = {
  Team      = "devops"
  Challenge = "30-day-terraform"
  CostCenter = "dev"
}
