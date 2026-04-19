# Resource Groups Module

resource "aws_resourcegroups_group" "main" {
  name        = "${var.project_name}-resource-group"
  description = "Resource group for all ${var.project_name} resources"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        {
          Key    = "Project"
          Values = [var.project_name]
        }
      ]
    })
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-resource-group" })
}
