resource "aws_docdb_cluster" "docdb_cluster" {
  cluster_identifier = "docdb-cluster"
  master_username    = var.db_username
  master_password    = var.db_password
  engine             = "docdb"
  engine_version     = var.docdb_engine_version
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.docdb_security_group_id]
  skip_final_snapshot = true 
  tags = {
    Name = "DocumentDBCluster"
  }
}

resource "aws_docdb_cluster_instance" "lila_mongo_instance" {
  cluster_identifier = aws_docdb_cluster.docdb_cluster.id
  instance_class     = var.docdb_instance_class
  engine             = "docdb"

  tags = {
    Name = "lila-mongo-instance"
  }
}

resource "aws_security_group_rule" "allow_ecs_to_docdb" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  security_group_id        = var.docdb_security_group_id # SG для DocumentDB
  source_security_group_id = var.codebuild_security_group_id  # Зміна на SG для MongoDB
}
