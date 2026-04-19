# Glue Module - Data Catalog and ETL

resource "aws_glue_catalog_database" "main" {
  name        = "${replace(var.project_name, "-", "_")}_db"
  description = "Glue catalog database for ${var.project_name}"
}

resource "aws_glue_catalog_table" "main" {
  name          = "${replace(var.project_name, "-", "_")}_table"
  database_name = aws_glue_catalog_database.main.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }

  storage_descriptor {
    location      = "s3://${var.s3_bucket_name}/data/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "json-serde"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "id"
      type = "string"
    }
    columns {
      name = "timestamp"
      type = "string"
    }
    columns {
      name = "value"
      type = "double"
    }
  }
}

resource "aws_glue_crawler" "main" {
  name          = "${var.project_name}-crawler"
  role          = var.glue_role_arn
  database_name = aws_glue_catalog_database.main.name
  description   = "Crawler for ${var.project_name} data"

  s3_target {
    path = "s3://${var.s3_bucket_name}/data/"
  }

  schedule = "cron(0 12 * * ? *)"

  tags = merge(var.common_tags, { Name = "${var.project_name}-glue-crawler" })
}

resource "aws_glue_job" "main" {
  name         = "${var.project_name}-etl-job"
  role_arn     = var.glue_role_arn
  glue_version = "4.0"
  description  = "ETL job for ${var.project_name}"

  command {
    name            = "glueetl"
    script_location = "s3://${var.s3_bucket_name}/scripts/etl.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"        = "python"
    "--enable-metrics"      = ""
    "--enable-auto-scaling" = "true"
  }

  number_of_workers = 2
  worker_type       = "G.1X"

  tags = merge(var.common_tags, { Name = "${var.project_name}-glue-job" })
}

resource "aws_glue_trigger" "main" {
  name     = "${var.project_name}-glue-trigger"
  type     = "SCHEDULED"
  schedule = "cron(0 1 * * ? *)"

  actions {
    job_name = aws_glue_job.main.name
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-glue-trigger" })
}
