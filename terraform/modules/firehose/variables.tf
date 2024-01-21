variable "kafka_cluster_arn" {
  type = string
}

variable "cloud_watch_logs_arn" {
  type = string
}

variable "firehose_key_arn" {
  type      = string
  sensitive = true
}
