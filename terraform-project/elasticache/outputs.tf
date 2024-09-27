output "elasticache_cluster_id" {
  description = "The ID of the ElastiCache cluster"
  value       = aws_elasticache_cluster.redis.cluster_id
}

output "redis_endpoint" {
  description = "The endpoint of the ElastiCache node"
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}
