# Day 9 — Module Versioning

**Concept:** Pinning module and provider versions for reproducible builds.

## The Problem

*"Without version pinning, `terraform init` on Monday may pull different code than Friday."*

An unpinned module source means your team could silently pull breaking changes.

## Version Pinning Examples

```hcl
# Pin to a git tag instead of a local path:
source  = "git::https://github.com/yourorg/tf-modules.git//networking?ref=v1.2.0"

# Provider version constraint:
version = "~> 5.40"   # ~> means: 5.x but NOT 6.0
```

## Version Constraint Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `= 5.40` | Exact version only | Rarely used |
| `>= 5.40` | This version or higher | Loose — risky |
| `~> 5.40` | 5.40.x only (patch updates ok) | Recommended |
| `~> 5.0` | 5.x (minor updates ok) | Common for providers |

## Demo: What Breaks Without Pinning

```bash
# Simulate: change a module's variable name
# → terraform plan shows destroy/recreate of real infrastructure
# Then revert and add a version pin → stable
```

## Key File

`shared/versions.tf` — all provider version pins live here.

## Talking Points

- `~>` is the "pessimistic constraint operator" — the safe default.
- Pins = reproducibility. Same `terraform init` result today, next year, on any machine.
- Commit `.terraform.lock.hcl` in real projects — it's the exact provider hash.
