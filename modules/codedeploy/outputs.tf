output "ec2_app_name" { value = aws_codedeploy_app.ec2.name }
output "lambda_app_name" { value = aws_codedeploy_app.lambda.name }
output "ecs_app_name" { value = aws_codedeploy_app.ecs.name }
