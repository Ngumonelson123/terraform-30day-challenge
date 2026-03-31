# Day 8 — Modules

**Concept:** Extracting reusable code into modules. DRY infrastructure.

## Before vs After

```hcl
# BEFORE (Day 3 inline) — 80+ lines in main.tf:
resource "aws_vpc" "main" { ... }
resource "aws_subnet" "public" { ... }
resource "aws_internet_gateway" "main" { ... }
# ... 80 more lines

# AFTER (Day 8 module call) — 6 lines:
module "networking" {
  source  = "./modules/networking"
  vpc_cidr = var.vpc_cidr
  ...
}
```

*"The networking module is ~100 lines. You call it in 6. Reuse it in every project."*

## Module Output Chaining

```hcl
module.networking.vpc_id      → module.security.vpc_id
module.security.app_sg_id     → module.compute.app_sg_id
module.compute.alb_dns_name   → cloudflare_record.app.value  (Day 15 preview)
```

## Key Modules

| Module | Purpose | Introduced |
|--------|---------|-----------|
| `modules/networking` | VPC, subnets, IGW, routes | Day 4 inline → Day 8 module |
| `modules/security` | Security groups for all tiers | Day 3 inline → Day 8 module |
| `modules/compute` | ASG, launch template, ALB | Day 5 inline → Day 8 module |
| `modules/database` | RDS MySQL | Day 8 |

## Talking Points

- Modules have **inputs** (variables), **outputs**, and encapsulated resources.
- A module is just a folder with `.tf` files.
- `source = "./modules/networking"` — local path. Day 9 shows remote/versioned sources.
