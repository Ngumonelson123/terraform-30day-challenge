# =============================================================================
# backend.tf
# DAY 6: Move state from local file to a remote, shared, locked backend.
#
# WHY: Local terraform.tfstate breaks in a team — two people apply at the
# same time and one overwrites the other. S3 stores the state centrally.
# DynamoDB adds a lock so only one apply runs at a time.
#
# HOW TO DEMO:
#   1. Show terraform.tfstate existing locally after Day 5 apply.
#   2. Add this file, run `terraform init` — Terraform asks to migrate state.
#   3. Confirm yes. State is now in S3.
#   4. Run `terraform plan` twice in two terminals simultaneously to show lock.
# =============================================================================

terraform {
  backend "s3" {
    # Replace <your-name> with your own unique suffix
    bucket  = "tf-challenge-state-nelson"
    key     = "landing-zone/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true

    # DAY 6: DynamoDB table for state locking
    dynamodb_table = "tf-state-lock"
  }
}

# =============================================================================
# HOW TO CREATE THE BACKEND RESOURCES (run once before terraform init):
#
# aws s3 mb s3://tf-challenge-state-nelson --region us-east-1
#
# aws dynamodb create-table \
#   --table-name tf-state-lock \
#   --attribute-definitions AttributeName=LockID,AttributeType=S \
#   --key-schema AttributeName=LockID,KeyType=HASH \
#   --billing-mode PAY_PER_REQUEST \
#   --region us-east-1
# =============================================================================
