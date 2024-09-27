variable "mongo_domain" {
  type = string
  description = "Domain for MongoDB"
}

variable "github_repo_url" {
  type        = string
  description = "URL до GitHub репозиторію"
}

variable "s3_cache_bucket" {
  type        = string
  description = "S3 бакет для кешування"
}

variable "lila_domain" {
  type = string
  description = "Domain for Lila"
}

variable "redis_domain" {
  type = string
  description = "Domain for Redis"
}

variable "docker_username" {
  type = string
}

variable "docker_password" {
  type = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private Subnet IDs"
  type        = list(string)
}

variable "docdb_security_group_id" {
  description = "DocumentDB Security Group ID"
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

variable "docdb_endpoint" {
  type        = string
  description = "The endpoint for the DocumentDB cluster"
}

variable "app_version" {
  type        = string
  description = "The app version"
}
