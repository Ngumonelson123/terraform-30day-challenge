# Day 13 — Sensitive Data

**Concept:** Keeping secrets out of code, tfvars, and plan output.

## The Three Levels Demo

```bash
# BAD — password in tfvars:
terraform plan -var="db_password=supersecret"
# Plan output shows: db_password = "supersecret"  ← visible to everyone!

# BETTER — mark sensitive in variables.tf:
# Plan output shows: db_password = (sensitive value)  ← hidden in output
# BUT it's still in tfvars → still in git history. Not good enough.

# BEST — SSM Parameter Store:
aws ssm put-parameter \
  --name /tfc/dev/db_password \
  --type SecureString \
  --value "Demo@Pass123!"
# Terraform reads it via a data source — never in tfvars, never in git
```

## The SSM Pattern

```hcl
# main.tf — read the password from SSM at plan time
data "aws_ssm_parameter" "db_password" {
  count           = local.rds_count
  name            = "/${var.project}/${var.environment}/db_password"
  with_decryption = true
}

# Pass to the database module — value is marked sensitive automatically
module "database" {
  db_password = data.aws_ssm_parameter.db_password[0].value
}
```

## The sensitive = true Flag

```hcl
# modules/database/variables.tf
variable "db_password" {
  type      = string
  sensitive = true  # DAY 13: value is redacted in ALL plan/apply output
}
```

## Show the .gitignore

```bash
cat shared/.gitignore | grep -E "tfstate|secret|env"
```

## Key Files

- `shared/variables.tf` — `db_password` with `sensitive = true`
- `shared/modules/database/main.tf` — `storage_encrypted = true` on RDS
- `shared/modules/database/variables.tf` — sensitive variable
- `shared/.gitignore` — what must never be committed

## Talking Points

- **Three rules:** Never in code. Never in tfvars. Never in an output.
- `sensitive = true` hides the value from the terminal but NOT from the state file.
- SSM SecureString encrypts at rest with KMS. Only IAM-authorised roles can decrypt.
- The database module intentionally has NO `db_password` output — read from SSM directly when needed.
