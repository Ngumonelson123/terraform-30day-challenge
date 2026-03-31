# =============================================================================
# envs/prod/terraform.tfvars
# DAY 7: Production — bigger, redundant, all features on.
#        Use with: terraform apply -var-file="envs/prod/terraform.tfvars"
#
# DAY 7 DEMO POINT — Workspaces vs file layout:
#   Workspaces:   terraform workspace select prod → same code, separate state
#   File layout:  -var-file="envs/prod/terraform.tfvars" → explicit, auditable
#
# File layout wins for prod/dev because:
#   - Each env can have a completely different backend block
#   - PRs clearly show which env changes
#   - No risk of accidentally applying dev plan to prod state
# =============================================================================

project     = "tfc"
environment = "prod"
aws_region  = "us-east-1"

vpc_cidr             = "10.10.0.0/16"
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]

ami_id               = "ami-0c02fb55956c7d316"
instance_type        = "t3.small"
asg_min_size         = 2
asg_max_size         = 6
asg_desired_capacity = 2

# DAY 11: In prod everything is on
enable_bastion        = false  # Prod uses SSM Session Manager instead
enable_rds            = true
enable_nat_gateway    = true
enable_datadog        = true
enable_cloudflare_dns = true

db_instance_class = "db.t3.small"
db_name           = "appdb"
db_username       = "admin"

# DAY 15: Set your real domain details here
app_hostname       = "app.yourdomain.com"
cloudflare_zone_id = "YOUR_ZONE_ID"

common_tags = {
  Team       = "devops"
  Challenge  = "30-day-terraform"
  CostCenter = "prod"
}
