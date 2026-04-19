output "cluster_id" { value = aws_elasticache_cluster.redis.id }
output "cluster_address" { value = aws_elasticache_cluster.redis.cache_nodes[0].address }
output "replication_group_id" { value = aws_elasticache_replication_group.main.id }
