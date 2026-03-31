# 🎤 Live Demo Script — Terraform 30-Day Challenge Midpoint Pulse Check
## Day 1–15 End-to-End Walkthrough

**Audience:** Challenge participants (Day 15 midpoint)
**Format:** Live terminal + VS Code side-by-side
**Duration:** ~45–60 minutes

---

## Setup Before You Go Live

```bash
# 1. Have these open and ready:
#    - VS Code: the shared/ folder
#    - Terminal 1: for terraform commands
#    - Terminal 2: for AWS CLI verification
#    - Browser tab: AWS Console (EC2, S3, RDS)
#    - Browser tab: terraform.io/docs

# 2. Ensure AWS credentials are set
export AWS_PROFILE=your-profile   # or
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...

# 3. Run bootstrap (state backend + SSM secret)
chmod +x scripts/bootstrap.sh && ./scripts/bootstrap.sh
```

---

## Day 1 — "Why Terraform? What is IaC?"
**File:** `versions.tf`, open AWS console

**Say:** *"Before Terraform, this is what infrastructure looked like..."*
→ Click around the AWS Console — create an EC2, set a security group, pick a subnet.
→ Ask: "What happens when you need 10 of these? In 3 environments? At 2am?"

**Show:** `versions.tf`
```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.40" }
  }
}
```
**Say:** *"One file. Declarative. Version-pinned. Reproducible on any machine."*

---

## Day 2 — "Setting Up the Environment"
**Commands to run live:**
```bash
terraform init        # Show .terraform/ folder appear
terraform fmt         # Auto-format all .tf files
terraform validate    # Catch syntax errors before plan
terraform version     # Show installed version
```

**Show:** `.terraform/providers/` — the downloaded AWS plugin
**Say:** *"`terraform init` is like `npm install` — it fetches the providers declared in versions.tf."*

---

## Day 3 — "First Server"
**File:** `main.tf` → `aws_instance.bastion` block, `modules/security/main.tf`

```bash
terraform plan -target=aws_instance.bastion -target=module.security
```

**Walk through the plan output:**
- `+` green = will be created
- Show the security group with port 22 ingress
- Show `ami_id`, `instance_type`, `subnet_id`

```bash
terraform apply -target=module.networking -target=module.security -target=aws_instance.bastion
```

**Verify live:**
```bash
terraform output bastion_public_ip
ssh -i your-key.pem ec2-user@<ip>
```

---

## Day 4 — "Variables, Outputs, VPC"
**Files:** `variables.tf`, `outputs.tf`, `modules/networking/main.tf`

**Demo validation:**
```bash
terraform plan -var="environment=banana"   # Watch it fail with the error message
```

**Show `terraform.tfvars` → how values flow in without touching the code.**

---

## Day 5 — "Scaling & Local State"
**File:** `modules/compute/main.tf` (ASG section)

```bash
cat terraform.tfstate | jq '.resources[0]'
terraform apply -var="asg_desired_capacity=2"
```

---

## Day 6 — "Remote State"
**File:** `backend.tf`

```bash
terraform init   # Detects backend change, asks to migrate → yes
aws s3 ls s3://tf-challenge-state-nelson/landing-zone/
```

**Demo locking (two terminals simultaneously):**
```bash
# Terminal 1: terraform apply
# Terminal 2: terraform plan   → Error: Error acquiring the state lock
```

---

## Day 7 — "Workspaces vs File Layout"
```bash
terraform workspace list
terraform workspace new staging
terraform workspace select staging
terraform plan
terraform workspace select dev
```

```bash
aws s3 ls s3://tf-challenge-state-nelson/env:/
# dev/, staging/ — separate state files
```

```bash
terraform apply -var-file="envs/prod/terraform.tfvars"
```

---

## Day 8 — "Modules"
**Files:** `modules/networking/`, `modules/compute/`, `modules/security/`

Show the before (80 inline lines) vs after (6-line module call).

Show output chaining:
```hcl
module.networking.vpc_id      → module.security.vpc_id
module.security.app_sg_id     → module.compute.app_sg_id
module.compute.alb_dns_name   → cloudflare_record.app.value
```

---

## Day 9 — "Module Versioning"
**File:** `versions.tf`

```hcl
source  = "git::https://github.com/yourorg/tf-modules.git//networking?ref=v1.2.0"
version = "~> 5.40"
```

*"Without version pinning, `terraform init` on Monday may pull different code than Friday."*

---

## Day 10 — "Loops: for_each & dynamic"
**Files:** `modules/networking/main.tf`, `modules/security/main.tf`

Show count (fragile, index-based) vs for_each (stable, key-based).
Show the `dynamic "ingress"` block replacing 3 repeated ingress blocks.

---

## Day 11 — "Conditionals"
**Files:** `locals.tf`, `variables.tf`

```bash
terraform plan -var="enable_bastion=false"
terraform plan -var="enable_bastion=true"
```

Show `locals.tf` — environment-aware instance sizing.

---

## Day 12 — "Zero-Downtime Deploy"
**File:** `modules/compute/main.tf`

```bash
while true; do curl -s http://$(terraform output -raw alb_dns_name) | grep Instance; sleep 1; done
```

Change `ami_id` in tfvars, then `terraform apply`. Watch curl stay up throughout.

Key code: `create_before_destroy = true`, `instance_refresh { strategy = "Rolling" }`

---

## Day 13 — "Sensitive Data"
**Files:** `variables.tf`, `main.tf` (SSM data source)

Show the three levels: plaintext in tfvars → `sensitive = true` → SSM Parameter Store.

```bash
cat .gitignore | grep -E "tfstate|secret|env"
```

---

## Day 14 — "Multiple Providers Part 1: Datadog"
```bash
export TF_VAR_datadog_api_key="your-api-key"
export TF_VAR_datadog_app_key="your-app-key"
terraform apply -var="enable_datadog=true"
```

Open Datadog in the browser — show the monitor appearing live.

---

## Day 15 — "Multiple Providers Part 2: The Full Chain"
```bash
export TF_VAR_cloudflare_api_token="your-token"
terraform apply -var="enable_cloudflare_dns=true"
```

Show the dependency chain: AWS ELB → `alb_dns_name` output → Cloudflare record.

```bash
terraform output alb_dns_name
dig app.yourdomain.com
curl https://app.yourdomain.com
```

---

## Grand Finale — Destroy and Rebuild

```bash
terraform destroy -var-file="envs/dev/terraform.tfvars"
time terraform apply -var-file="envs/dev/terraform.tfvars" -auto-approve
```

*"From zero to a full production-grade AWS environment in under 5 minutes. That's what Days 1–15 built."*
