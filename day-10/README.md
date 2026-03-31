# Day 10 — Loops: for_each & dynamic

**Concept:** Key-based iteration with `for_each`; eliminating repeated blocks with `dynamic`.

## count vs for_each — The Key Difference

```bash
# count — positional, FRAGILE:
aws_subnet.public[0]
aws_subnet.public[1]
# Remove [0] → [1] becomes [0] → Terraform DESTROYS and RECREATES it!

# for_each — key-based, STABLE:
aws_subnet.public["10.0.1.0/24"]
aws_subnet.public["10.0.2.0/24"]
# Remove first → second is completely untouched
```

## for_each in the Networking Module

```hcl
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : cidr => {
    cidr = cidr
    az   = var.azs[idx % length(var.azs)]
  }}

  cidr_block        = each.value.cidr
  availability_zone = each.value.az
}
```

## dynamic Block in Security Module

```hcl
dynamic "ingress" {
  for_each = var.bastion_ingress_rules
  content {
    from_port   = ingress.value.from_port
    to_port     = ingress.value.to_port
    protocol    = ingress.value.protocol
    cidr_blocks = ingress.value.cidr_blocks
    description = ingress.value.description
  }
}
```

Without `dynamic`: you'd repeat the `ingress { }` block once per rule.

## Key Files

- `shared/modules/networking/main.tf` — `for_each` on public and private subnets
- `shared/modules/security/main.tf` — `dynamic "ingress"` block
- `shared/modules/compute/main.tf` — `dynamic "tag"` block on ASG

## Talking Points

- Use `for_each` over `count` whenever the items have a natural stable key (CIDR, name, ID).
- `dynamic` replaces copy-pasted nested blocks. If you've written the same block 3 times, use `dynamic`.
- `each.key` and `each.value` are the loop variables inside a `for_each` resource.
