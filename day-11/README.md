# Day 11 — Conditionals

**Concept:** Toggling resources on/off per environment using conditionals and locals.

## Live Demo — Toggle the Bastion

```bash
terraform plan -var="enable_bastion=false"
# Output: aws_instance.bastion[0] will be destroyed

terraform plan -var="enable_bastion=true"
# Output: aws_instance.bastion[0] will be created
```

## The Pattern

```hcl
# In locals.tf:
bastion_count = var.enable_bastion ? 1 : 0

# In main.tf:
resource "aws_instance" "bastion" {
  count = local.bastion_count   # clean, readable
  ...
}
```

## Environment-Aware Sizing

```hcl
# locals.tf — prod gets larger instances automatically
effective_instance_type = var.environment == "prod" ? "t3.small" : var.instance_type
effective_asg_min       = var.environment == "prod" ? 2 : var.asg_min_size
```

*"One codebase, different behaviour per environment. Zero duplication."*

## Feature Flags Summary

| Variable | dev | prod |
|----------|-----|------|
| `enable_bastion` | `true` | `false` (use SSM Session Manager) |
| `enable_rds` | `false` | `true` |
| `enable_nat_gateway` | `false` | `true` |
| `enable_datadog` | `false` | `true` |
| `enable_cloudflare_dns` | `false` | `true` |

## Key Files

- `shared/locals.tf` — all conditionals and computed locals
- `shared/variables.tf` — feature flag variable declarations

## Talking Points

- **Never delete resources** to "turn them off." Use `count = 0`.
- `locals.tf` is where expressions live. Keep `main.tf` clean.
- The ternary `condition ? true_val : false_val` is Terraform's only conditional expression.
