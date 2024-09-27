variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr_1" {
  description = "CIDR block for the first public subnet"
  type        = string
}

variable "public_subnet_cidr_2" {
  description = "CIDR block for the second public subnet"
  type        = string
}

variable "private_subnet_cidr_1" {
  description = "CIDR block for the first private subnet"
  type        = string
}

variable "private_subnet_cidr_2" {
  description = "CIDR block for the second private subnet"
  type        = string
}

variable "public_availability_zone_1" {
  description = "Availability zone for the first public subnet"
  type        = string
}

variable "public_availability_zone_2" {
  description = "Availability zone for the second public subnet"
  type        = string
}

variable "private_availability_zone_1" {
  description = "Availability zone for the first private subnet"
  type        = string
}

variable "private_availability_zone_2" {
  description = "Availability zone for the second private subnet"
  type        = string
}
