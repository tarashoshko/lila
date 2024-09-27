variable "aws_region" {
  description = "Region for AWS resources"
  default     = "eu-central-1"
}

variable "aws_access_key" {
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
}

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

variable "private_availability_zone_1" {
  description = "Availability zone for the first private subnet"
  type        = string
}

variable "private_availability_zone_2" {
  description = "Availability zone for the second private subnet"
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

variable "db_username" {
  description = "Database master username"
  type        = string
}

variable "db_password" {
  description = "Database master password"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the DocumentDB subnet group"
  type        = string
}

variable "docker_username" {
  type = string
}

variable "docker_password" {
  type = string
}

variable "app_version" {
  type        = string
  description = "The app version"
}
