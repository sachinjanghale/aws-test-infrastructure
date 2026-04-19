output "parameter_names" {
  value = [aws_ssm_parameter.string.name, aws_ssm_parameter.secure_string.name, aws_ssm_parameter.string_list.name]
}
