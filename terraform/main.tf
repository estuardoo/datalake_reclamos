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

# ------------------------------
# S3 BUCKETS
# ------------------------------
resource "aws_s3_bucket" "datalake" {
  bucket        = var.datalake_bucket
  force_destroy = true
}

resource "aws_s3_bucket" "athena_results" {
  bucket        = var.athena_results_bucket
  force_destroy = true
}

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

# ------------------------------
# GLUE / ATHENA
# ------------------------------
resource "aws_glue_catalog_database" "db" {
  name = "datalake_db"
}

resource "aws_glue_catalog_table" "reclamos" {
  database_name = aws_glue_catalog_database.db.name
  name          = "reclamos_ml"
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://${var.datalake_bucket}/raw/reclamos/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    # OJO: en el provider AWS v5 el bloque se llama ser_de_info (no serde_info)
    ser_de_info {
      name                  = "OpenCSVSerde"
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"
      parameters = {
        separatorChar = ","
        quoteChar     = "\""
        escapeChar    = "\\"
      }
    }

    # Cada columna va como bloque 'columns' (no como lista)
    columns { 
      name = "id_reclamo"
      type = "bigint"
    }
    columns { 
      name = "id_cliente"
      type = "int"
    }
    columns { 
      name = "id_tarjeta"
      type = "int"
    }
    columns { 
      name = "tipo_codigo"
      type = "string"
    }
    columns { 
      name = "tipo_nombre"
      type = "string"
    }
    columns { 
      name = "criticidad"
      type = "string"
    }
    columns { 
      name = "estado_codigo"
      type = "string"
    }
    columns { 
      name = "estado_nombre"
      type = "string"
    }
    columns { 
      name = "canal_codigo"
      type = "string"
    }
    columns { 
      name = "canal_nombre"
      type = "string"
    }
    columns { 
      name = "descripcion"
      type = "string"
    }
    columns { 
      name = "monto"
      type = "double"
    }
    columns { 
      name = "moneda_codigo"
      type = "string"
    }
    columns { 
      name = "fecha_apertura"
      type = "string"
    }
    columns { 
      name = "fecha_cierre"
      type = "string"
    }
    columns { 
      name = "sla_dias"
      type = "int"
    }
    columns { 
      name = "dias_transcurridos"
      type = "int"
    }
    # En el CSV hay True/False; para evitar conflictos lo dejamos como string
    columns { 
      name = "en_sla"
      type = "string"
    }
    columns { 
      name = "referencia_externa"
      type = "string"
    }
    columns { 
      name = "movimientos_count"
      type = "int"
    }
    columns { 
      name = "ultimo_id_movimiento"
      type = "bigint"
    }
    columns { 
      name = "decision_resultado"
      type = "string"
    }
    columns { 
      name = "decision_monto_reintegrar"
      type = "double"
    }
    columns { 
      name = "decision_fecha_decision"
      type = "string"
    }
  }

  parameters = {
    classification           = "csv"
    "skip.header.line.count" = "1"
    EXTERNAL                 = "TRUE"
  }
}

# ------------------------------
# CARGA DEL CSV AL DATALAKE
# ------------------------------
# Sube data/abc-reclamos-ml.csv
