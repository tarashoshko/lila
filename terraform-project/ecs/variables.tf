variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "docdb_endpoint" {
  type        = string
  description = "The endpoint for the DocumentDB cluster"
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

variable "mongo_domain" {
  type = string
  description = "Domain for MongoDB"
}

variable "lila_domain" {
  type = string
  description = "Domain for Lila"
}

variable "redis_domain" {
  type = string
  description = "Domain for Redis"
}
