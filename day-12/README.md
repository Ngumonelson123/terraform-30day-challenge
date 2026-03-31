# Day 12 — Zero-Downtime Deploy

**Concept:** Rolling AMI updates with ALB + `create_before_destroy` lifecycle.

## Setup

Make sure the ALB and ASG are deployed from earlier steps.

## The Demo

```bash
# Step 1: Watch the ALB serve traffic continuously
while true; do curl -s http://$(terraform output -raw alb_dns_name) | grep Instance; sleep 1; done

# Step 2: Simulate a new app version (change ami_id in terraform.tfvars)
terraform apply -var-file="envs/dev/terraform.tfvars"
```

**Watch live:** New instances come up → register with ALB → old ones drain → curl never returns a 502.

## The Key Code

```hcl
# modules/compute/main.tf

resource "aws_launch_template" "app" {
  lifecycle {
    create_before_destroy = true  # new template exists before old is gone
  }
}

resource "aws_autoscaling_group" "app" {
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90   # at most 10% of fleet down at once
      instance_warmup        = 60
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "app" {
  deregistration_delay = 30  # ALB waits for in-flight requests to complete
}
```

## How it Works

```
1. AMI ID changes in tfvars
      ↓
2. New Launch Template version created
      ↓
3. ASG instance_refresh triggers rolling replace
      ↓
4. New instances boot + register with ALB target group
      ↓
5. ALB health check passes → traffic shifts
      ↓
6. Old instances drain (30s) → terminated
```

## Key File

`shared/modules/compute/main.tf` — Launch Template, ASG, ALB, Target Group.

## Talking Points

- `create_before_destroy` reverses the default order: Terraform creates the replacement first.
- `min_healthy_percentage = 90` means at most 1-in-10 instances is replaced at a time.
- The ALB is the traffic gatekeeper — it only routes to instances that pass the health check.
