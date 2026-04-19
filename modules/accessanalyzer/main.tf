# Access Analyzer Module

resource "aws_accessanalyzer_analyzer" "account" {
  analyzer_name = "${var.project_name}-account-analyzer"
  type          = "ACCOUNT"

  tags = merge(var.common_tags, { Name = "${var.project_name}-access-analyzer" })
}
