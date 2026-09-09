variable "name" {
  description = "Nombre de la red"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
}

variable "private_subnets" {
  description = "Subredes privadas"
  type        = list(string)
}

variable "public_subnets" {
  description = "Subredes publicas"
  type        = list(string)
}

variable "environment" {
  description = "Ambiente"
  type        = string
}