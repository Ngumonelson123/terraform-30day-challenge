# Day 15 — Multiple Providers Part 2: The Full Chain

**Concept:** Wiring AWS output → Cloudflare DNS in a single `terraform apply`. The Day 1–15 payoff.

## Setup

```bash
export TF_VAR_cloudflare_api_token="your-token"
terraform apply -var="enable_cloudflare_dns=true"
```

## The Money Shot — Dependency Chain

```
AWS ELB API
    ↓
module.compute.alb_dns_name  (Terraform output)
    ↓
cloudflare_record.app.value  (input to Cloudflare resource)
    ↓
Cloudflare API → live DNS record
```

```hcl
# main.tf — output from AWS feeds directly into Cloudflare
resource "cloudflare_record" "app" {
  count   = var.enable_cloudflare_dns ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = var.app_hostname
  type    = "CNAME"
  value   = module.compute.alb_dns_name  # ← AWS output → Cloudflare input
  proxied = true
}
```

## Verify After Apply

```bash
terraform output alb_dns_name
dig app.yourdomain.com       # Should resolve!
curl https://app.yourdomain.com
```

## The Grand Finale — Destroy and Rebuild

```bash
# Destroy everything
terraform destroy -var-file="envs/dev/terraform.tfvars"

# Rebuild from zero — time it
time terraform apply -var-file="envs/dev/terraform.tfvars" -auto-approve
```

*"From zero to a full production-grade AWS environment in under 5 minutes. That's what Days 1–15 built."*

## What One `terraform apply` Provisions

| Resource | Day Introduced |
|----------|---------------|
| VPC, subnets, IGW, route tables | Day 4 |
| Security groups (bastion, ALB, app, DB) | Day 3 |
| Bastion host (conditional) | Day 3 / Day 11 |
| Auto Scaling Group + Launch Template | Day 5 |
| Application Load Balancer | Day 12 |
| RDS MySQL (conditional) | Day 13 |
| Datadog CPU + 5xx monitors (conditional) | Day 14 |
| Cloudflare DNS record (conditional) | Day 15 |

## Closing Line

*"From Day 1 — one provider block — to Day 15: three providers, one state file, one apply.
VPC, subnets, bastion, ASG, ALB, RDS, Datadog monitors, and DNS — all declared as code,
all reproducible, all auditable in git. That is infrastructure as code."*
