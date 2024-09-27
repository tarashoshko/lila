provider "aws" {
  region = var.region
}

resource "aws_elasticache_parameter_group" "redis_parameter_group" {
  name   = var.parameter_group_name
  family = "redis7"
  description = "Parameter group for Redis 7"
}
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = var.cluster_id
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = var.parameter_group_name
  port                 = var.port
  maintenance_window   = var.maintenance_window
  snapshot_window      = var.snapshot_window
  security_group_ids   = var.security_group_ids
  subnet_group_name    = var.subnet_group_name

  tags = {
    Name = "RedisCluster"
  }
}
