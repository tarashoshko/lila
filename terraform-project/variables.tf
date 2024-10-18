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

variable "db_username" {
  description = "Database master username"
  type        = string
}

variable "db_password" {
  description = "Database master password"
  type        = string
}

variable "docker_username" {
  type = string
}

variable "docker_password" {
  type = string
}
