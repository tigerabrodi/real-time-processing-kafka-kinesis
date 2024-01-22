output "kafka_cluster_arn" {
  value     = aws_msk_cluster.kafka_cluster.arn
  sensitive = true
}

output "scram_secret_name" {
  value     = aws_secretsmanager_secret.scram_secret.name
  sensitive = true
}
