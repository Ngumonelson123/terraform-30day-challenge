# =============================================================================
# main.tf — Root module
#
# DAY 1:  Provider block
# DAY 3:  Bastion host (count conditional)
# DAY 4:  Networking module
# DAY 5:  Compute module (count-based scaling)
# DAY 6:  Remote state already configured in backend.tf
# DAY 8:  Module calls replace inline resources
# DAY 12: ALB wired to ASG for zero-downtime deploys
# DAY 13: SSM data source for DB password
# DAY 14: Datadog provider + monitors (disabled until ready)
# DAY 15: Cloudflare provider + DNS record (disabled until ready)
# =============================================================================

# -----------------------------------------------------------------------------
# DAY 1: Provider configuration
# -----------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# DAY 14: Uncomment when Datadog is ready
# provider "datadog" {
#   validate = false
#   api_key  = var.datadog_api_key
#   app_key  = var.datadog_app_key
# }

# DAY 15: Uncomment when Cloudflare is ready
# provider "cloudflare" {
#   api_token = var.cloudflare_api_token
# }

provider "random" {}

# Random suffix so resource names are globally unique (S3 bucket names etc.)
resource "random_id" "suffix" {
  byte_length = 4
}

# =============================================================================
# DAY 4 & 8: NETWORKING MODULE
# Provisions VPC, public/private subnets, IGW, route tables, NAT gateway.
# =============================================================================
module "networking" {
  source = "./modules/networking"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = local.azs
  enable_nat_gateway   = var.enable_nat_gateway
  nat_count            = local.nat_count
  tags                 = local.common_tags
}

# =============================================================================
# DAY 3 & 8: SECURITY GROUPS MODULE
# Creates security groups for bastion, ALB, app tier, and RDS.
# =============================================================================
module "security" {
  source = "./modules/security"

  name_prefix          = local.name_prefix
  vpc_id               = module.networking.vpc_id
  bastion_allowed_cidr = var.bastion_allowed_cidr
  tags                 = local.common_tags
}

# =============================================================================
# DAY 3 & 11: BASTION HOST
# count = local.bastion_count evaluates to 0 (off) or 1 (on)
# =============================================================================
resource "aws_instance" "bastion" {
  count = local.bastion_count

  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = module.networking.public_subnet_ids[0]
  vpc_security_group_ids      = [module.security.bastion_sg_id]
  key_name                    = var.ssh_key_name != "" ? var.ssh_key_name : null
  associate_public_ip_address = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bastion"
    Day  = "Day3-Day11"
  })
}

# =============================================================================
# DAY 5, 8, 10, 12: COMPUTE MODULE
# ASG + Launch Template + ALB.
# =============================================================================
module "compute" {
  source = "./modules/compute"

  name_prefix       = local.name_prefix
  ami_id            = var.ami_id
  instance_type     = local.effective_instance_type
  min_size          = local.effective_asg_min
  max_size          = local.effective_asg_max
  desired_capacity  = local.effective_asg_desired
  subnet_ids        = module.networking.private_subnet_ids
  public_subnet_ids = module.networking.public_subnet_ids
  vpc_id            = module.networking.vpc_id
  alb_sg_id         = module.security.alb_sg_id
  app_sg_id         = module.security.app_sg_id
  key_name          = var.ssh_key_name != "" ? var.ssh_key_name : null
  tags              = local.common_tags
}

# =============================================================================
# DAY 13: SENSITIVE DATA — SSM Parameter Store
# =============================================================================
data "aws_ssm_parameter" "db_password" {
  count           = local.rds_count
  name            = "/${var.project}/${var.environment}/db_password"
  with_decryption = true
}

# =============================================================================
# DAY 13 & 8: DATABASE MODULE
# RDS MySQL — only deployed when enable_rds = true
# =============================================================================
module "database" {
  count  = local.rds_count
  source = "./modules/database"

  name_prefix    = local.name_prefix
  subnet_ids     = module.networking.private_subnet_ids
  db_sg_id       = module.security.db_sg_id
  instance_class = var.db_instance_class
  db_name        = var.db_name
  db_username    = var.db_username
  db_password    = data.aws_ssm_parameter.db_password[0].value
  tags           = local.common_tags
}

# =============================================================================
# DAY 14: DATADOG MONITORS — uncomment when ready
# =============================================================================
# resource "datadog_monitor" "high_cpu" {
#   count = var.enable_datadog ? 1 : 0
#
#   name    = "${local.name_prefix} - High CPU"
#   type    = "metric alert"
#   message = "CPU above 80% on ${local.name_prefix} ASG. @slack-devops"
#
#   query = "avg(last_5m):avg:aws.ec2.cpuutilization{project:${var.project},env:${var.environment}} > 80"
#
#   monitor_thresholds {
#     critical = 80
#     warning  = 70
#   }
#
#   tags = [
#     "project:${var.project}",
#     "env:${var.environment}",
#     "managed_by:terraform",
#   ]
# }
#
# resource "datadog_monitor" "alb_5xx" {
#   count = var.enable_datadog ? 1 : 0
#
#   name    = "${local.name_prefix} - ALB 5xx errors"
#   type    = "metric alert"
#   message = "5xx errors spiking on ALB. @pagerduty"
#
#   query = "sum(last_5m):sum:aws.applicationelb.httpcode_elb_5xx{project:${var.project}}.as_count() > 10"
#
#   monitor_thresholds {
#     critical = 10
#     warning  = 5
#   }
#
#   tags = [
#     "project:${var.project}",
#     "env:${var.environment}",
#     "managed_by:terraform",
#   ]
# }

# =============================================================================
# DAY 15: CLOUDFLARE DNS — uncomment when ready
# =============================================================================
# resource "cloudflare_record" "app" {
#   count = var.enable_cloudflare_dns ? 1 : 0
#
#   zone_id = var.cloudflare_zone_id
#   name    = var.app_hostname
#   type    = "CNAME"
#   value   = module.compute.alb_dns_name
#   proxied = true
#   ttl     = 1
#
#   comment = "Managed by Terraform - ${local.name_prefix}"
# }