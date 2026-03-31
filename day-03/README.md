# Day 3 — First Server (Bastion Host)

**Concept:** Writing your first resource, running `terraform plan` and `apply`.

## Commands to Run Live

```bash
# Plan just the bastion and security group
terraform plan -target=aws_instance.bastion -target=module.security

# Apply
terraform apply -target=module.networking -target=module.security -target=aws_instance.bastion

# Verify: get the public IP
terraform output bastion_public_ip
ssh -i your-key.pem ec2-user@<ip>
```

## What to Walk Through in the Plan Output

- `+` green = will be **created**
- Show the security group with port 22 ingress
- Show `ami_id`, `instance_type`, `subnet_id` values

## Key Files

- `shared/main.tf` → `aws_instance.bastion` block
- `shared/modules/security/main.tf` → `aws_security_group.bastion`

## Talking Points

- Every resource has a **type** (`aws_instance`) and a **name** (`bastion`).
- The plan shows exactly what will happen — nothing is created until you type `yes`.
- The bastion SG restricts SSH to your IP only. Security starts on Day 3.
