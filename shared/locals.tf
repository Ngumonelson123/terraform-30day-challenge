# =============================================================================
# locals.tf
# DAY 11: locals{} is where you put computed, conditional, and derived values.
#         It keeps main.tf clean and avoids repeating the same expression.
#
# RULE: If you write the same expression more than once → move it to locals.
# =============================================================================

locals {
  # -----------------------------------------------------------------------
  # Naming convention: <project>-<environment>-<resource>
  # Centralising this means changing "tfc" updates every resource name at once.
  # -----------------------------------------------------------------------
  name_prefix = "${var.project}-${var.environment}"

  # -----------------------------------------------------------------------
  # Availability zones — pulled dynamically so the code works in any region
  # -----------------------------------------------------------------------
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # -----------------------------------------------------------------------
  # DAY 11: Conditionals
  # count = local.bastion_count     ← clean, readable at the call site
  # -----------------------------------------------------------------------
  bastion_count = var.enable_bastion ? 1 : 0
  rds_count     = var.enable_rds ? 1 : 0
  nat_count     = var.enable_nat_gateway ? length(local.azs) : 0

  # -----------------------------------------------------------------------
  # DAY 11: Environment-specific sizing
  # Prod gets larger instances; dev uses the variable default (t3.micro).
  # -----------------------------------------------------------------------
  effective_instance_type = var.environment == "prod" ? "t3.small" : var.instance_type

  effective_asg_min     = var.environment == "prod" ? 2 : var.asg_min_size
  effective_asg_max     = var.environment == "prod" ? 6 : var.asg_max_size
  effective_asg_desired = var.environment == "prod" ? 2 : var.asg_desired_capacity

  # -----------------------------------------------------------------------
  # Common tags merged with environment-specific ones
  # Every resource gets these — no more forgetting to tag things.
  # -----------------------------------------------------------------------
  common_tags = merge(
    var.common_tags,
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
      Workspace   = terraform.workspace
    }
  )
}

# Data source needed by locals above
data "aws_availability_zones" "available" {
  state = "available"
}
