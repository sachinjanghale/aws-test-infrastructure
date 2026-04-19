# AppSync Module - GraphQL API

resource "aws_appsync_graphql_api" "main" {
  name                = "${var.project_name}-graphql-api"
  authentication_type = "API_KEY"

  schema = <<-EOF
    type Query {
      getItem(id: ID!): Item
      listItems: [Item]
    }
    type Mutation {
      createItem(name: String!): Item
    }
    type Item {
      id: ID!
      name: String!
      createdAt: String
    }
    schema {
      query: Query
      mutation: Mutation
    }
  EOF

  log_config {
    cloudwatch_logs_role_arn = var.appsync_role_arn
    field_log_level          = "ERROR"
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-appsync" })
}
