

output "scram_secret_name" {
  value     = module.aws_msk.scram_secret_name
  sensitive = true
}


output "kafka_cluster_arn" {
  value     = module.aws_msk.kafka_cluster_arn
  sensitive = true
}
