# Day 14 — Multiple Providers Part 1: Datadog

**Concept:** Terraform manages any platform with an API — not just AWS.

## Setup

```bash
export TF_VAR_datadog_api_key="your-api-key"
export TF_VAR_datadog_app_key="your-app-key"
terraform apply -var="enable_datadog=true"
```

Open Datadog in the browser — watch the monitor appear live after apply.

## Two Providers in One Project

```hcl
# versions.tf
required_providers {
  aws     = { source = "hashicorp/aws" }
  datadog = { source = "DataDog/datadog" }   # ← SaaS, not AWS
}

# main.tf
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}
```

## The Monitors Created

```hcl
# High CPU alert
resource "datadog_monitor" "high_cpu" {
  count   = var.enable_datadog ? 1 : 0
  name    = "${local.name_prefix} — High CPU"
  type    = "metric alert"
  query   = "avg(last_5m):avg:aws.ec2.cpuutilization{...} > 80"
  message = "CPU above 80% on ASG. @slack-devops"

  monitor_thresholds {
    critical = 80
    warning  = 70
  }
}

# ALB 5xx error spike
resource "datadog_monitor" "alb_5xx" { ... }
```

## Key File

`shared/main.tf` — provider `"datadog"` block and `datadog_monitor` resources.

## Talking Points

- *"Terraform manages anything with an API — cloud, SaaS, DNS, databases, monitoring — all from the same `plan`/`apply` workflow."*
- The Datadog resources use the same `count = var.enable_datadog ? 1 : 0` pattern from Day 11.
- Tags work across providers: `managed_by:terraform` appears in both AWS and Datadog.
- Credentials go in environment variables (`TF_VAR_*`), never in `.tf` files.
