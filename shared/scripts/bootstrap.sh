#!/usr/bin/env bash
# =============================================================================
# scripts/bootstrap.sh
# Run ONCE before `terraform init` to create the S3+DynamoDB state backend
# and seed the DB password into SSM Parameter Store.
#
# DAY 6 DEMO: Run this script, then show backend.tf and do terraform init.
# DAY 13 DEMO: Show the SSM parameter being created here — Terraform never
#              sees the raw value, only reads it via a data source at plan time.
# =============================================================================

set -euo pipefail

# ---- Config — edit these ----
BUCKET_NAME="tf-challenge-state-nelson"
REGION="us-east-1"
LOCK_TABLE="tf-state-lock"
PROJECT="tfc"
ENVIRONMENT="dev"
# ---- End config ----

echo "==> Creating S3 state bucket: $BUCKET_NAME"
aws s3 mb "s3://${BUCKET_NAME}" --region "${REGION}" 2>/dev/null || echo "    Bucket already exists, skipping."

echo "==> Enabling versioning on bucket (protects against accidental state deletion)"
aws s3api put-bucket-versioning \
  --bucket "${BUCKET_NAME}" \
  --versioning-configuration Status=Enabled

echo "==> Enabling server-side encryption on bucket"
aws s3api put-bucket-encryption \
  --bucket "${BUCKET_NAME}" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}
    }]
  }'

echo "==> Creating DynamoDB lock table: $LOCK_TABLE"
aws dynamodb create-table \
  --table-name "${LOCK_TABLE}" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "${REGION}" 2>/dev/null || echo "    Table already exists, skipping."

echo ""
echo "==> DAY 13: Seeding DB password into SSM Parameter Store"
echo "    (Terraform will read this via a data source — never stored in tfvars)"
read -rsp "    Enter a DB password to store in SSM: " DB_PASS
echo ""

aws ssm put-parameter \
  --name "/${PROJECT}/${ENVIRONMENT}/db_password" \
  --type "SecureString" \
  --value "${DB_PASS}" \
  --overwrite \
  --region "${REGION}"

echo ""
echo "==> Done! Now run:"
echo "    terraform init"
echo "    terraform workspace new dev"
echo "    terraform plan -var-file=envs/dev/terraform.tfvars"
