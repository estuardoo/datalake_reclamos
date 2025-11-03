terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ---- Buckets ----
resource "aws_s3_bucket" "datalake" {
  bucket        = var.datalake_bucket
  force_destroy = true
}

resource "aws_s3_bucket" "athena_results" {
  bucket        = var.athena_results_bucket
  force_destroy = true
}

# ---- Versioning ----
resource "aws_s3_bucket_versioning" "datalake" {
  bucket = aws_s3_bucket.datalake.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "athena_results" {
  bucket = aws_s3_bucket.athena_results.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ---- Glue Database ----
resource "aws_glue_catalog_database" "db" {
  name = "datalake_db"
}

# ---- Glue Table ----
resource "aws_glue_catalog_table" "reclamos" {
  database_name = aws_glue_catalog_database.db.name
  name          = "reclamos_ml"
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://${var.datalake_bucket}/raw/reclamos/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    serde_info {
      name                  = "OpenCSVSerde"
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"
      parameters = {
        "separatorChar" = ","
        "quoteChar"     = "\""
        "escapeChar"    = "\\"
      }
    }

    columns = [
      { name = "id_reclamo", type = "bigint" },
      { name = "id_cliente", type = "int" },
      { name = "id_tarjeta", type = "int" },
      { name = "tipo_codigo", type = "string" },
      { name = "tipo_nombre", type = "string" },
      { name = "criticidad", type = "string" },
      { name = "estado_codigo", type = "string" },
      { name = "estado_nombre", type = "string" },
      { name = "canal_codigo", type = "string" },
      { name = "canal_nombre", type = "string" },
      { name = "descripcion", type = "string" },
      { name = "monto", type = "double" },
      { name = "moneda_codigo", type = "string" },
      { name = "fecha_apertura", type = "string" },
      { name = "fecha_cierre", type = "string" },
      { name = "sla_dias", type = "int" },
      { name = "dias_transcurridos", type = "int" },
      { name = "en_sla", type = "boolean" },
      { name = "referencia_externa", type = "string" },
      { name = "movimientos_count", type = "int" },
      { name = "ultimo_id_movimiento", type = "bigint" },
      { name = "decision_resultado", type = "string" },
      { name = "decision_monto_reintegrar", type = "double" },
      { name = "decision_fecha_decision", type = "string" }
    ]
  }

  parameters = {
    "classification"         = "csv"
    "skip.header.line.count" = "1"
    "EXTERNAL"               = "TRUE"
  }
}

# ---- Upload CSV ----
resource "aws_s3_object" "csv_reclamos" {
  bucket = aws_s3_bucket.datalake.id
  key    = "raw/reclamos/abc-reclamos-ml.csv"
  source = "${path.module}/../data/abc-reclamos-ml.csv"
  etag   = filemd5("${path.module}/../data/abc-reclamos-ml.csv")
}
