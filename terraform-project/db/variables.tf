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

variable "docdb_subnet_ids" {
  description = "List of subnet IDs for DocumentDB"
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID where DocumentDB and ECS are deployed"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "VPC Security Group IDs for DocumentDB"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "Name of the DocumentDB subnet group"
  type        = string
}

variable "docdb_engine_version" {
  type        = string
  description = "The engine version of DocumentDB"
  default     = "5.0"
}

variable "docdb_instance_class" {
  type        = string
  description = "The instance class for DocumentDB cluster instance"
  default     = "db.t3.medium"
}

variable "docdb_security_group_id" {
  description = "DocumentDB Security Group ID"
  type        = string
}
 
variable "codebuild_security_group_id" {
  description = "CodeBuild Security Group ID"
  type        = string
}
