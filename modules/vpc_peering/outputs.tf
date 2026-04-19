output "peering_connection_id" { value = aws_vpc_peering_connection.main.id }
output "peer_vpc_id" { value = aws_vpc.peer.id }
