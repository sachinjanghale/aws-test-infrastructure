output "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "hosted_zone_name" {
  description = "Route53 hosted zone name"
  value       = aws_route53_zone.main.name
}

output "name_servers" {
  description = "Route53 hosted zone name servers"
  value       = aws_route53_zone.main.name_servers
}

output "zone_arn" {
  description = "Route53 hosted zone ARN"
  value       = aws_route53_zone.main.arn
}

output "estimated_cost" {
  description = "Estimated monthly cost for Route53 resources"
  value       = 0.50 # $0.50 per hosted zone per month
}
