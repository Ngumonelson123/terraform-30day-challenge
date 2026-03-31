# modules/database/variables.tf

variable "name_prefix" { type = string }
variable "subnet_ids"  { type = list(string) }
variable "db_sg_id"    { type = string }

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "tags" {
  type    = map(string)
  default = {}
}

# DAY 13: sensitive = true — value is redacted in plan/apply output
variable "db_password" {
  type      = string
  sensitive = true
}