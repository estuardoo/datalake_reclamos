variable "region" {
  description = "Región AWS"
  type        = string
}

variable "datalake_bucket" {
  description = "Bucket principal del Data Lake"
  type        = string
}

variable "athena_results_bucket" {
  description = "Bucket donde Athena guardará los resultados"
  type        = string
}
