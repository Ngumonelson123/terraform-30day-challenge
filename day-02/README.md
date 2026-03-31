# Day 2 — Setting Up the Environment

**Concept:** Initialising Terraform, formatting, validating.

## Commands to Run Live

```bash
terraform init        # Show .terraform/ folder appear
terraform fmt         # Auto-format all .tf files
terraform validate    # Catch syntax errors before plan
terraform version     # Show installed version
```

## What to Show

- After `terraform init`, open `.terraform/providers/` — the downloaded AWS plugin.
- Explain: *"`terraform init` is like `npm install` — it fetches the providers declared in versions.tf."*

## Key Concepts

| Command | What it does |
|---------|-------------|
| `terraform init` | Downloads providers, sets up backend |
| `terraform fmt` | Auto-formats `.tf` files to canonical style |
| `terraform validate` | Checks syntax without connecting to AWS |
| `terraform version` | Shows installed CLI and provider versions |

## File Reference

→ `shared/versions.tf` (from Day 1)
