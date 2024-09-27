variable "region" {
  description = "The AWS region to deploy the ElastiCache cluster"
  type        = string
  default     = "eu-central-1"
}

variable "cluster_id" {
  description = "The identifier for the ElastiCache cluster"
  type        = string
  default     = "redis-cluster-id"
}

variable "node_type" {
  description = "The node type for the ElastiCache cluster"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "The number of cache nodes"
  type        = number
  default     = 1
}

variable "parameter_group_name" {
  description = "The name of the parameter group"
  type        = string
  default     = "my-redis-parameter-group"
}

variable "port" {
  description = "The port for the ElastiCache cluster"
  type        = number
  default     = 6379
}

variable "maintenance_window" {
  description = "The maintenance window for the ElastiCache cluster"
  type        = string
  default     = "sun:05:00-sun:09:00"
}

variable "snapshot_window" {
  description = "The snapshot window for the ElastiCache cluster"
  type        = string
  default     = "00:00-01:10"
}

variable "security_group_ids" {
  description = "The security group IDs for the ElastiCache cluster"
  type        = list(string)
}

variable "subnet_group_name" {
  description = "Name of the ElastiCache subnet group"
  type        = string
}
