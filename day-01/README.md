# Day 1 — Why Terraform? What is IaC?

**Concept:** Infrastructure as Code — the problem Terraform solves.

## What to Show

- Open the AWS Console and manually click through creating an EC2: security group, subnet, AMI.
- Ask the audience: *"What happens when you need 10 of these? In 3 environments? At 2am?"*
- Then show `versions.tf` — one file, declarative, version-pinned, reproducible on any machine.

## Key File

**`versions.tf`** — Terraform's entry point. Declares the required Terraform version and every provider plugin the project needs.

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.40" }
  }
}
```

## Talking Points

- **Declarative vs Imperative:** You describe *what* you want, not *how* to build it.
- **Version-pinned:** `~> 5.40` means 5.x but not 6.0. Same code, same result on any machine.
- **Reproducible:** `versions.tf` checked into git = entire team uses identical provider versions.

## File Reference

→ `shared/versions.tf`
