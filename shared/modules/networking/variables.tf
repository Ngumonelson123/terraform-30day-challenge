# modules/networking/variables.tf

variable "name_prefix"          { type = string }
variable "vpc_cidr"             { type = string }
variable "public_subnet_cidrs"  { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "azs"                  { type = list(string) }

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "nat_count" {
  type    = number
  default = 0
}

variable "tags" {
  type    = map(string)
  default = {}
}