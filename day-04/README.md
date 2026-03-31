# Day 4 — Variables, Outputs, VPC

**Concept:** Making code reusable with variables and exposing values with outputs.

## What to Demo

### Variable Validation
```bash
# Watch it fail with the custom error message
terraform plan -var="environment=banana"
```

### Show how values flow in
Open `shared/terraform.tfvars` — values here override `variables.tf` defaults without touching the code.

## Key Files

- `shared/variables.tf` — all input variable declarations with types, defaults, and validation
- `shared/outputs.tf` — values exposed after apply
- `shared/modules/networking/main.tf` — VPC, subnets, IGW, route tables

## Highlight: Validation Block

```hcl
variable "environment" {
  type    = string
  default = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod."
  }
}
```

Validation runs at **plan time** — before anything touches AWS.

## Talking Points

- Variables = inputs. Outputs = return values.
- `terraform.tfvars` is the config file — check it in (minus secrets).
- The VPC CIDR, subnet CIDRs, and AZs are all variables. One change → entire network adapts.
