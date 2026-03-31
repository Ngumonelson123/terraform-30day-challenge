# =============================================================================
# versions.tf
# DAY 1: This is where Terraform learns WHAT providers (plugins) it needs.
# DAY 9: We pin exact versions so the team always gets the same behaviour.
# =============================================================================

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    # AWS — our main cloud provider
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }

    # DAY 14-15: Uncomment when ready to use Datadog
    # datadog = {
    #   source  = "DataDog/datadog"
    #   version = "~> 3.39"
    # }

    # DAY 15: Uncomment when ready to use Cloudflare
    # cloudflare = {
    #   source  = "cloudflare/cloudflare"
    #   version = "~> 4.30"
    # }

    # Random — used to generate unique resource name suffixes
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}