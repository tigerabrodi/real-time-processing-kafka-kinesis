output "kafka_cluster_arn" {
  value     = aws_msk_cluster.kafka_cluster.arn
  sensitive = true
}
