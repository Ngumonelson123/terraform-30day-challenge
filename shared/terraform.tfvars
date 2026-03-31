# =============================================================================
# terraform.tfvars — Dev defaults
# DAY 4: This is how you supply variable values without editing variables.tf.
#
# NEVER commit secrets here. Passwords and API keys go in:
#   - Environment variables: TF_VAR_db_password="..."
#   - AWS SSM Parameter Store (see Day 13)
#   - A secrets.auto.tfvars that is in .gitignore
# =============================================================================

project     = "tfc"
environment = "dev"
aws_region  = "us-east-1"

# Networking
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

# Compute
ami_id               = "ami-0c02fb55956c7d316"
instance_type        = "t3.micro"
asg_min_size         = 1
asg_max_size         = 2
asg_desired_capacity = 1

# DAY 11: Feature flags — keep most things off in dev to save cost
enable_bastion        = true
enable_rds            = false
enable_nat_gateway    = false
enable_datadog        = false
enable_cloudflare_dns = false

# Replace with your own IP: curl ifconfig.me
bastion_allowed_cidr = "0.0.0.0/0"

# Replace with your EC2 key pair name
ssh_key_name = "my-key-pair"

common_tags = {
  Team      = "devops"
  Challenge = "30-day-terraform"
}
