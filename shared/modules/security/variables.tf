# modules/security/variables.tf

variable "name_prefix" { type = string }
variable "vpc_id"      { type = string }

variable "bastion_allowed_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "tags" {
  type    = map(string)
  default = {}
}

# DAY 10: ingress rules as a variable — passed as a list of objects
# This drives the dynamic block in main.tf
variable "bastion_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH"
    }
  ]
}