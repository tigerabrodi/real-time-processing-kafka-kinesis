output "firehose_key_arn" {
  value     = aws_kms_key.firehose_key.arn
  sensitive = true
}
