resource "aws_s3_bucket" "data_lake" {
  bucket = "tiger-kun-ecommerce-data-lake"
}

resource "aws_s3_bucket_ownership_controls" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "data_lake" {
  depends_on = [aws_s3_bucket_ownership_controls.data_lake]

  bucket = aws_s3_bucket.data_lake.id
  acl    = "private"
}

# Creates an IAM role for AWS Kinesis Firehose.
resource "aws_iam_role" "firehose_role" {
  name = "firehose_delivery_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      },
    ]
  })
}

# Defines an IAM policy with permissions for Firehose.
resource "aws_iam_policy" "firehose_policy" {
  name = "firehose_delivery_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.data_lake.arn}",
          "${aws_s3_bucket.data_lake.arn}/*"
        ]
      },
      {
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Effect = "Allow",
        Resource = [
          var.firehose_key_arn
        ]
      },
      {
        Action = [
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = [
          var.cloud_watch_logs_arn
        ]
      },
      {
        Action = [
          "kafka:DescribeCluster",
          "kafka:GetBootstrapBrokers",
          "kafka:ListScramSecrets"
        ],
        Effect = "Allow",
        Resource = [
          var.kafka_cluster_arn
        ]
      },
      {
        Action = [
          "kinesis:DescribeStream"
        ],
        Effect = "Allow",
        Resource = [
          aws_kinesis_stream.kinesis_stream.arn
        ]
      },
    ]
  })
}

# Attaches the IAM policy to the Firehose IAM role.
resource "aws_iam_role_policy_attachment" "firehose_attach" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}

resource "aws_kinesis_stream" "kinesis_stream" {
  name        = "kinesis-stream"
  shard_count = 3
}

# Creates a Kinesis Firehose delivery stream to transfer data to S3.
resource "aws_kinesis_firehose_delivery_stream" "firehose_to_s3" {
  name        = "firehose-to-s3-stream"
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.data_lake.arn
  }

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.kinesis_stream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }
}
