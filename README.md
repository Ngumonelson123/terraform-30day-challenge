# Terraform 30-Day Challenge — Day 1–15 Demo Project

A structured, day-by-day walkthrough of a production-grade AWS landing zone built with Terraform.

## Project Structure

```
terraform-30day-challenge/
│
├── day-01/   Why Terraform? What is IaC?
├── day-02/   Setting Up the Environment
├── day-03/   First Server (Bastion Host)
├── day-04/   Variables, Outputs, VPC
├── day-05/   Scaling & Local State
├── day-06/   Remote State (S3 + DynamoDB)
├── day-07/   Workspaces vs File Layout
├── day-08/   Modules
├── day-09/   Module Versioning
├── day-10/   Loops: for_each & dynamic
├── day-11/   Conditionals
├── day-12/   Zero-Downtime Deploy
├── day-13/   Sensitive Data (SSM)
├── day-14/   Multiple Providers — Datadog
├── day-15/   Multiple Providers — Cloudflare + Full Chain
│
└── shared/                    ← The actual Terraform code
    ├── main.tf                # Root module — orchestrates everything
    ├── variables.tf           # All input variables
    ├── outputs.tf             # All outputs
    ├── versions.tf            # Provider version pins (Day 1 + Day 9)
    ├── backend.tf             # Remote state config (Day 6)
    ├── locals.tf              # Computed/conditional locals (Day 11)
    ├── terraform.tfvars       # Dev defaults
    ├── .gitignore
    ├── scripts/
    │   └── bootstrap.sh       # One-time S3 + DynamoDB + SSM setup
    ├── envs/
    │   ├── dev/terraform.tfvars
    │   └── prod/terraform.tfvars
    └── modules/
        ├── networking/        # VPC, subnets, IGW, route tables
        ├── compute/           # ASG, Launch Template, ALB
        ├── security/          # Security groups
        └── database/          # RDS MySQL
```

## How to Use This Repo

Each `day-XX/` folder contains a `README.md` that explains:
- The concept introduced that day
- Exactly which commands to run and what to show
- Which file(s) to open in `shared/`
- Key talking points

The `shared/` folder is where the actual Terraform lives — open it in VS Code alongside the terminal.

## Quick Start

```bash
cd shared/

# 1. Create the state backend (one time only)
chmod +x scripts/bootstrap.sh && ./scripts/bootstrap.sh

# 2. Initialise Terraform
terraform init

# 3. Create a workspace
terraform workspace new dev

# 4. Plan and apply
terraform plan  -var-file="envs/dev/terraform.tfvars"
terraform apply -var-file="envs/dev/terraform.tfvars"

# 5. Tear down when done
terraform destroy -var-file="envs/dev/terraform.tfvars"
```

## Day-by-Day Concept Map

| Day | Concept | Key File(s) |
|-----|---------|------------|
| 1  | Why IaC? Provider block | `versions.tf` |
| 2  | init, fmt, validate | CLI commands |
| 3  | First EC2, plan/apply | `main.tf` (bastion), `modules/security/` |
| 4  | Variables, outputs, VPC | `variables.tf`, `outputs.tf`, `modules/networking/` |
| 5  | count, local state | `modules/compute/`, `terraform.tfstate` |
| 6  | Remote state, locking | `backend.tf`, `scripts/bootstrap.sh` |
| 7  | Workspaces vs file layout | `envs/dev/`, `envs/prod/` |
| 8  | Modules | `modules/` structure, module calls in `main.tf` |
| 9  | Module versioning | `versions.tf` version constraints |
| 10 | for_each, dynamic blocks | `modules/networking/`, `modules/security/` |
| 11 | Conditionals, locals | `locals.tf`, feature flags in `variables.tf` |
| 12 | Zero-downtime deploy | `modules/compute/` (ALB + lifecycle) |
| 13 | Sensitive data, SSM | `modules/database/`, `variables.tf` sensitive flag |
| 14 | Multi-provider: Datadog | `main.tf` datadog_monitor resources |
| 15 | Multi-provider: Cloudflare | `main.tf` cloudflare_record + full chain |
