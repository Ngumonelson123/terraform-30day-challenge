# =============================================================================
# modules/networking/main.tf
# DAY 4: VPC, subnets, internet gateway, route tables
# DAY 8: This code was originally inline in main.tf — now it's a module.
#        The caller (root main.tf) just does: module "networking" { source = ... }
# DAY 11: NAT gateway count driven by var.nat_count (0 in dev, 2 in prod)
# =============================================================================

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpc" })
}

# Internet Gateway — allows public subnets to reach the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-igw" })
}

# =============================================================================
# DAY 10: for_each replaces count for subnets
# WHY: count uses index — if you remove subnet[0], subnet[1] gets renamed to [0]
#      and Terraform destroys+recreates it. for_each uses a stable key (the CIDR).
# =============================================================================

# Public subnets
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : cidr => {
    cidr = cidr
    az   = var.azs[idx % length(var.azs)]
  }}

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-${each.value.az}"
    Tier = "public"
  })
}

# Private subnets
resource "aws_subnet" "private" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : cidr => {
    cidr = cidr
    az   = var.azs[idx % length(var.azs)]
  }}

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-${each.value.az}"
    Tier = "private"
  })
}

# =============================================================================
# Public route table — sends 0.0.0.0/0 → IGW
# =============================================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-rt-public" })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# =============================================================================
# DAY 11: NAT Gateway — conditional, count driven by var.nat_count
# In dev: nat_count = 0 → no NAT gateway, saves ~$32/month
# In prod: nat_count = 2 → one per AZ for high availability
# =============================================================================
resource "aws_eip" "nat" {
  count  = var.nat_count
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.name_prefix}-eip-nat-${count.index}" })
}

resource "aws_nat_gateway" "main" {
  count         = var.nat_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = values(aws_subnet.public)[count.index].id

  tags = merge(var.tags, { Name = "${var.name_prefix}-nat-${count.index}" })

  depends_on = [aws_internet_gateway.main]
}

# Private route table — sends 0.0.0.0/0 → NAT gateway (when enabled)
resource "aws_route_table" "private" {
  count  = var.nat_count > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-rt-private" })
}

resource "aws_route_table_association" "private" {
  for_each = var.nat_count > 0 ? aws_subnet.private : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
}
