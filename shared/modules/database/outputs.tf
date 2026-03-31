# modules/database/outputs.tf

output "db_endpoint" {
  description = "RDS connection endpoint (host:port)."
  value       = aws_db_instance.main.endpoint
}

output "db_name" {
  value = aws_db_instance.main.db_name
}

# NOTE: db_password is intentionally NOT exposed as an output.
# Read it directly from SSM when needed:
#   aws ssm get-parameter --name /tfc/dev/db_password --with-decryption
