# =============================================================================
# variables.tf
# DAY 4: Variables make your code reusable. Instead of hardcoding values,
#        we declare inputs here and supply values via terraform.tfvars.
# DAY 11: Conditionals — some variables toggle features on/off per env.
# DAY 13: sensitive = true hides values from plan/apply output and state.
# =============================================================================

# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------
variable "project" {
  description = "Short project name — used in all resource name prefixes."
  type        = string
  default     = "tfc"

  # DAY 4: Validation blocks enforce rules at plan time, before anything deploys.
  validation {
    condition     = length(var.project) <= 8 && can(regex("^[a-z0-9-]+$", var.project))
    error_message = "project must be lowercase alphanumeric, max 8 chars."
  }
}

variable "environment" {
  description = "Deployment environment (dev | staging | prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "common_tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Networking (Day 4 — modules/networking)
# -----------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets (one per AZ)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDRs for private subnets (one per AZ)."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# -----------------------------------------------------------------------------
# Compute (Days 3, 5, 10 — modules/compute)
# -----------------------------------------------------------------------------
variable "ami_id" {
  description = "AMI ID for EC2 instances (Amazon Linux 2023)."
  type        = string
  default     = "ami-0c02fb55956c7d316" # us-east-1 Amazon Linux 2023
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Minimum number of instances in the ASG."
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in the ASG."
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in the ASG."
  type        = number
  default     = 2
}

# DAY 11: Conditional — toggle the bastion host on/off per environment
variable "enable_bastion" {
  description = "Set to true to deploy a bastion host in the public subnet."
  type        = bool
  default     = true
}

variable "bastion_allowed_cidr" {
  description = "Your IP CIDR allowed to SSH into the bastion (e.g. 1.2.3.4/32)."
  type        = string
  default     = "0.0.0.0/0" # Restrict this in production!
}

variable "ssh_key_name" {
  description = "Name of an existing EC2 key pair for SSH access."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Database (Day 13 — modules/database)
# -----------------------------------------------------------------------------
variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Name of the initial database."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for RDS."
  type        = string
  default     = "admin"
}

# DAY 13: sensitive = true — this value is NEVER printed in plan/apply output.
#         We read it from SSM Parameter Store using a data source instead of
#         hardcoding it here.
variable "db_password" {
  description = "Master password for RDS. Leave empty — read from SSM."
  type        = string
  default     = ""
  sensitive   = true
}

# DAY 11: Toggle RDS on/off — saves cost in dev
variable "enable_rds" {
  description = "Set to true to deploy an RDS instance."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Feature flags (Day 11 — conditionals)
# -----------------------------------------------------------------------------
variable "enable_nat_gateway" {
  description = "Set to true to add a NAT gateway (needed for private subnet egress)."
  type        = bool
  default     = false # Off by default to save cost in dev
}

variable "enable_datadog" {
  description = "Set to true to create Datadog monitors."
  type        = bool
  default     = false
}

variable "enable_cloudflare_dns" {
  description = "Set to true to create a Cloudflare DNS record pointing to the ALB."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# External providers (Days 14–15)
# -----------------------------------------------------------------------------
variable "datadog_api_key" {
  description = "Datadog API key. Set via TF_VAR_datadog_api_key env var."
  type        = string
  default     = ""
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog APP key. Set via TF_VAR_datadog_app_key env var."
  type        = string
  default     = ""
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token. Set via TF_VAR_cloudflare_api_token env var."
  type        = string
  default     = ""
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for your domain."
  type        = string
  default     = ""
}

variable "app_hostname" {
  description = "Hostname for the application (e.g. app.yourdomain.com)."
  type        = string
  default     = "app.example.com"
}
