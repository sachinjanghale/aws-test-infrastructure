# VPC Peering Module (peering with itself for testing)

resource "aws_vpc" "peer" {
  cidr_block = "10.1.0.0/16"

  tags = merge(var.common_tags, { Name = "${var.project_name}-peer-vpc", Purpose = "Peer VPC for testing" })
}

resource "aws_vpc_peering_connection" "main" {
  vpc_id      = var.vpc_id
  peer_vpc_id = aws_vpc.peer.id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-vpc-peering" })
}
