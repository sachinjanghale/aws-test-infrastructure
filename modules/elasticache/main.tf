# ElastiCache Module - Redis cluster (minimal)

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-cache-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.common_tags, { Name = "${var.project_name}-cache-subnet-group" })
}

resource "aws_elasticache_parameter_group" "redis" {
  name   = "${var.project_name}-redis-params"
  family = "redis7"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-redis-params" })
}

# Single-node Redis cluster (cheapest option ~$12/month for cache.t3.micro)
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project_name}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.redis.name
  engine_version       = "7.0"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [var.security_group_id]

  tags = merge(var.common_tags, { Name = "${var.project_name}-redis" })
}

# Replication Group (edge case: multi-AZ Redis)
resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "${var.project_name}-redis-rg"
  description          = "Redis replication group for ${var.project_name}"
  node_type            = "cache.t3.micro"
  num_cache_clusters   = 1
  parameter_group_name = aws_elasticache_parameter_group.redis.name
  engine_version       = "7.0"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [var.security_group_id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  tags = merge(var.common_tags, { Name = "${var.project_name}-redis-rg" })
}
