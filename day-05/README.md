# Day 5 — Scaling & Local State

**Concept:** Using `count` for scaling; understanding the state file.

## What to Demo

### Show the local state file (before Day 6 migration)
```bash
cat terraform.tfstate | jq '.resources[0]'
```
*"This is the source of truth for your infrastructure. Lose it → Terraform loses track of everything it manages."*

### Scale the ASG live
```bash
# Change desired_capacity from 1 to 2
terraform apply -var="asg_desired_capacity=2"
```

## Key File

`shared/modules/compute/main.tf` — the Auto Scaling Group section.

## count vs for_each (Preview for Day 10)

```hcl
# count — positional, fragile:
aws_subnet.public[0]
aws_subnet.public[1]
# Remove [0] → [1] becomes [0] → Terraform destroys and recreates it!
```

Day 10 will fix this with `for_each`.

## Talking Points

- `count` makes N copies of a resource. Simple, but index-based.
- The `terraform.tfstate` file is sacred. Back it up. (Day 6 solves this with S3.)
- ASG `desired_capacity` can be changed with a single variable — no code changes needed.
