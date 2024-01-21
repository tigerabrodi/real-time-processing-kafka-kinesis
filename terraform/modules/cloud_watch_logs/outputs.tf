output "log_group_arn_firehose" {
  value = aws_cloudwatch_log_group.firehose_logs.arn
}
