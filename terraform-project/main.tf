provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "vpc" {
  source = "./vpc"

  vpc_cidr                  = var.vpc_cidr
  public_subnet_cidr_1         = var.public_subnet_cidr_1
  public_subnet_cidr_2         = var.public_subnet_cidr_2
  private_subnet_cidr_1        = var.private_subnet_cidr_1
  private_subnet_cidr_2        = var.private_subnet_cidr_2
  public_availability_zone_1   = var.public_availability_zone_1
  public_availability_zone_2   = var.public_availability_zone_2
  private_availability_zone_1  = var.private_availability_zone_1
  private_availability_zone_2  = var.private_availability_zone_2
}

resource "aws_docdb_subnet_group" "docdb_subnet_group" { 
  name       = "docdb-subnet-group" 
  subnet_ids = module.vpc.private_subnet_ids

  tags = {
    Name = "DocumentDBSubnetGroup"
  }
}

module "docdb" {
  source = "./db"

  db_username            = var.db_username
  db_password            = var.db_password
  db_name                = var.db_name
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_id                 = module.vpc.vpc_id

  docdb_subnet_ids       = module.vpc.private_subnet_ids
  vpc_security_group_ids = module.vpc.vpc_security_group_ids
  docdb_security_group_id = module.vpc.docdb_security_group_id
  codebuild_security_group_id = module.vpc.codebuild_security_group_id
}

module "ecs" {
  source = "./ecs"

  db_username            = var.db_username
  db_password            = var.db_password
  db_name                = var.db_name
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_ids = module.vpc.vpc_security_group_ids
  vpc_id             = module.vpc.vpc_id
  docdb_endpoint     = module.docdb.docdb_endpoint
  lila_domain = "localhost:9663"
  mongo_domain = "mongodb://username:var.db_password@module.docdb.docdb_endpoint:27017/?tls=true&tlsCAFile=build/global-bundle.pem&retryWrites=false"
  redis_domain = module.elasticache.redis_endpoint
}

resource "aws_s3_bucket" "lila_codebuild_cache" {
  bucket = "lila-codebuild-cache"
}

module "build" {
  source = "./build"

  github_repo_url = "https://github.com/tarashoshko/lila.git"
  docker_username = var.docker_username
  docker_password = var.docker_password
  s3_cache_bucket = aws_s3_bucket.lila_codebuild_cache.bucket
  lila_domain = "localhost:9663"
  mongo_domain = "mongodb://username:var.db_password@module.docdb.docdb_endpoint:27017/?ssl=true&sslCAFile=build/global-bundle.pem&retryWrites=false"
  redis_domain = module.elasticache.redis_endpoint
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  docdb_security_group_id    = module.vpc.codebuild_security_group_id
  db_username                = var.db_username
  db_password                = var.db_password
  docdb_endpoint             = module.docdb.docdb_endpoint
  app_version                = var.app_version
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = module.vpc.private_subnet_ids

  tags = {
    Name = "RedisSubnetGroup"
  }
}

module "elasticache" {
  source = "./elasticache"

  subnet_group_name        = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [module.vpc.docdb_security_group_id]
}
