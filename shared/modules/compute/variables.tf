# modules/compute/variables.tf

variable "name_prefix"       { type = string }
variable "ami_id"            { type = string }
variable "instance_type"     { type = string }
variable "min_size"          { type = number }
variable "max_size"          { type = number }
variable "desired_capacity"  { type = number }
variable "subnet_ids"        { type = list(string) }
variable "public_subnet_ids" { type = list(string) }
variable "vpc_id"            { type = string }
variable "alb_sg_id"         { type = string }
variable "app_sg_id"         { type = string }

variable "key_name" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}