output "docdb_endpoint" {
  value = aws_docdb_cluster.docdb_cluster.endpoint
}

output "docdb_cluster_id" {
  description = "The ID of the DocumentDB cluster"
  value = aws_docdb_cluster.docdb_cluster.id
}
