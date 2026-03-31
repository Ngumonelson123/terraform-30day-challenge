# =============================================================================
# modules/security/main.tf
# DAY 3:  Bastion security group — first SG you create
# DAY 10: dynamic block on ingress rules — replaces repeated rule blocks
# =============================================================================

# -----------------------------------------------------------------------------
# Bastion SG — SSH from operator IP only
# -----------------------------------------------------------------------------
resource "aws_security_group" "bastion" {
  name        = "${var.name_prefix}-sg-bastion"
  description = "Bastion host - SSH ingress"
  vpc_id      = var.vpc_id

  # DAY 10: dynamic block replaces writing the same ingress block 3 times
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-sg-bastion" })
}

# -----------------------------------------------------------------------------
# ALB SG — HTTP/HTTPS from anywhere (public-facing)
# -----------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-sg-alb"
  description = "Application Load Balancer - HTTP/HTTPS ingress"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-sg-alb" })
}

# -----------------------------------------------------------------------------
# App SG — only accepts traffic from ALB and bastion (not the internet directly)
# -----------------------------------------------------------------------------
resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-sg-app"
  description = "App tier - accepts only ALB and bastion traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "HTTP from ALB only"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "SSH from bastion only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-sg-app" })
}

# -----------------------------------------------------------------------------
# DB SG — only accepts traffic from the app tier
# -----------------------------------------------------------------------------
resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-sg-db"
  description = "RDS - accepts only app tier traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
    description     = "MySQL from app tier only"
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-sg-db" })
}
