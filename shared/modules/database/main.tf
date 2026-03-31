# =============================================================================
# modules/database/main.tf
# DAY 13: Sensitive data — RDS password comes from SSM Parameter Store.
#         It is NEVER in tfvars, NEVER printed in plan output.
#
# DEMO SEQUENCE FOR DAY 13:
#   1. Show what happens if you put password in tfvars: terraform plan shows it.
#   2. Mark variable sensitive = true: now it shows "(sensitive value)".
#   3. Move it to SSM:
#      aws ssm put-parameter \
#        --name /tfc/dev/db_password \
#        --type SecureString \
#        --value "Demo@Pass123!"
#   4. Use a data source to read it — Terraform never stores it in plan output.
# =============================================================================

resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, { Name = "${var.name_prefix}-db-subnet-group" })
}

resource "aws_db_instance" "main" {
  identifier        = "${var.name_prefix}-rds"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.instance_class
  allocated_storage = 20
  storage_encrypted = true # DAY 13: always encrypt at rest

  db_name  = var.db_name
  username = var.db_username

  # DAY 13: password flows in from SSM via the data source in root main.tf.
  # It is marked sensitive in variables.tf — Terraform hides it in output.
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]

  skip_final_snapshot     = true  # Set false in prod
  deletion_protection     = false # Set true in prod
  backup_retention_period = 7
  multi_az                = false # Set true in prod for HA

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rds"
    Day  = "Day13"
  })
}
