# EIP Module - Elastic IPs (standalone, not for NAT)

# Standalone EIP (edge case: EIP not attached to anything)
resource "aws_eip" "standalone" {
  domain = "vpc"
  tags   = merge(var.common_tags, { Name = "${var.project_name}-standalone-eip", Purpose = "Standalone EIP for testing" })
}

# EIP attached to EC2 instance
resource "aws_eip" "ec2" {
  count    = var.enable_ec2_eip ? 1 : 0
  domain   = "vpc"
  instance = var.ec2_instance_id
  tags     = merge(var.common_tags, { Name = "${var.project_name}-ec2-eip", Purpose = "EIP for EC2 instance" })
}

# ENI (Network Interface)
resource "aws_network_interface" "main" {
  subnet_id       = var.subnet_id
  security_groups = [var.security_group_id]
  description     = "Test network interface for ${var.project_name}"

  tags = merge(var.common_tags, { Name = "${var.project_name}-eni", Purpose = "Test ENI" })
}
