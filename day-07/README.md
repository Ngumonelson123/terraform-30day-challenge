# Day 7 — Workspaces vs File Layout

**Concept:** Two ways to manage multiple environments in Terraform.

## Workspaces Demo

```bash
terraform workspace list
terraform workspace new staging
terraform workspace select staging
terraform workspace show         # "staging"
terraform plan                   # completely separate state from dev
terraform workspace select dev
```

### Verify in S3
```bash
aws s3 ls s3://tf-challenge-state-nelson/env:/
# You'll see: dev/, staging/ — separate state files!
```

## File Layout Demo

```bash
# Apply with a specific env's variables
terraform apply -var-file="envs/prod/terraform.tfvars"
```

## Key Files

- `shared/envs/dev/terraform.tfvars` — dev is cheap: t3.micro, no NAT, no RDS
- `shared/envs/prod/terraform.tfvars` — prod is robust: t3.small, NAT HA, RDS, Datadog

## Workspaces vs File Layout

| | Workspaces | File Layout |
|---|---|---|
| State isolation | Same backend, different keys | Fully separate |
| Code | Same `.tf` files | Same `.tf` files |
| Best for | Ephemeral envs (staging, review) | prod/dev hard separation |
| Risk | Easy to apply wrong workspace | Explicit `-var-file` flag |

**Rule of thumb:** Use file layout for prod/dev. Workspaces for feature branches.
