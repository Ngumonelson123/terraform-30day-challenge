# Day 6 — Remote State

**Concept:** Moving state to S3 + DynamoDB for team safety and locking.

## The Problem

*"Two engineers, same laptop, 2am. Both run `terraform apply`. What happens to the state file?"*

Without remote state: one overwrites the other. Infrastructure chaos.

## Live Migration Commands

```bash
# backend.tf is already written — just re-init
terraform init   # Terraform detects backend change, asks to migrate
# Type: yes
```

### Verify state is now in S3
```bash
aws s3 ls s3://tf-challenge-state-nelson/landing-zone/
```

### Demo state locking (two terminals)
```bash
# Terminal 1:
terraform apply   # starts...

# Terminal 2 simultaneously:
terraform plan    # Error: Error acquiring the state lock
```

## Key File

`shared/backend.tf` — S3 bucket + DynamoDB lock table configuration.

## Talking Points

- S3 stores state centrally — everyone reads the same version.
- DynamoDB provides a **distributed lock** — only one `apply` runs at a time.
- Versioning on the S3 bucket = automatic state history. Accidental destroy? Roll back.
- Run `scripts/bootstrap.sh` once to create the bucket and table.
