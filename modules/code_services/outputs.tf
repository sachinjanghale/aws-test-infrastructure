output "codecommit_repository_url" {
  description = "CodeCommit repository clone URL (HTTPS)"
  value       = aws_codecommit_repository.main.clone_url_http
}

output "codecommit_repository_arn" {
  description = "CodeCommit repository ARN"
  value       = aws_codecommit_repository.main.arn
}

output "codecommit_repository_name" {
  description = "CodeCommit repository name"
  value       = aws_codecommit_repository.main.repository_name
}

output "codebuild_project_name" {
  description = "CodeBuild project name"
  value       = aws_codebuild_project.main.name
}

output "codebuild_project_arn" {
  description = "CodeBuild project ARN"
  value       = aws_codebuild_project.main.arn
}

output "codepipeline_name" {
  description = "CodePipeline name"
  value       = var.enable_codepipeline ? aws_codepipeline.main[0].name : null
}

output "codepipeline_arn" {
  description = "CodePipeline ARN"
  value       = var.enable_codepipeline ? aws_codepipeline.main[0].arn : null
}

output "estimated_cost" {
  description = "Estimated monthly cost for code services"
  value       = var.enable_codepipeline ? 1.00 : 0 # CodePipeline: $1/active pipeline
}
