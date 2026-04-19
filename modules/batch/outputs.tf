output "compute_environment_arn" { value = aws_batch_compute_environment.main.arn }
output "job_queue_arn" { value = aws_batch_job_queue.main.arn }
output "job_definition_arn" { value = aws_batch_job_definition.main.arn }
