resource "aws_cloudwatch_log_group" "firehose_logs" {
  name = "/aws/kinesisfirehose/firehose-to-s3-stream"
}
