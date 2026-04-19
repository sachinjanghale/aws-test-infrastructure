# Service Catalog Module

resource "aws_servicecatalog_portfolio" "main" {
  name          = "${var.project_name}-portfolio"
  description   = "Service Catalog portfolio for ${var.project_name}"
  provider_name = var.project_name

  tags = merge(var.common_tags, { Name = "${var.project_name}-portfolio" })
}
