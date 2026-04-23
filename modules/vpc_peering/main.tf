# VPC Peering Module

resource "aws_vpc" "peer" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, { Name = "${var.project_name}-peer-vpc", Purpose = "Peer VPC for testing" })
}

resource "aws_vpc_peering_connection" "main" {
  vpc_id      = var.vpc_id
  peer_vpc_id = aws_vpc.peer.id
  auto_accept = true

  # Only enable DNS resolution if both VPCs have DNS hostnames enabled
  accepter {
    allow_remote_vpc_dns_resolution = false
  }

  requester {
    allow_remote_vpc_dns_resolution = false
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-vpc-peering" })
}
