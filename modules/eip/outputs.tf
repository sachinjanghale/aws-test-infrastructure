output "standalone_eip" { value = aws_eip.standalone.public_ip }
output "eni_id" { value = aws_network_interface.main.id }
