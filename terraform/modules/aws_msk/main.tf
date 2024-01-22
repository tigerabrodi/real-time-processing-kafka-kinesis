# Using default vpc, subnets and security group for simplicity
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# Security group with my public IP address as variable
# Needed to let local node.js script publish records to Kafka
resource "aws_security_group" "msk_sg" {
  name        = "msk-security-group"
  description = "Security group for MSK cluster"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 9092
    to_port     = 9096
    protocol    = "tcp"
    cidr_blocks = ["${var.ip_address}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "msk-security-group"
  }
}

resource "aws_msk_configuration" "kafka_config" {
  kafka_versions = ["2.8.1"]
  name           = "kafka-config"

  # This is more readable than using inline string and placing \n as breakpoints
  # This lets us publish records to Kafka without having to create a topic first
  # If topic does not exist, it will be created automatically
  # More convenient for side project
  # Should not be used in production
  server_properties = <<EOF
auto.create.topics.enable = true
delete.topic.enable = true
EOF
}

resource "aws_msk_cluster" "kafka_cluster" {
  cluster_name           = "kafka-cluster"
  kafka_version          = "2.8.1"
  number_of_broker_nodes = 3

  depends_on = [aws_msk_configuration.kafka_config]
  configuration_info {
    arn      = aws_msk_configuration.kafka_config.arn
    revision = aws_msk_configuration.kafka_config.latest_revision
  }

  broker_node_group_info {
    instance_type   = "kafka.t3.small"
    client_subnets  = tolist(data.aws_subnets.default.ids)
    security_groups = [aws_security_group.msk_sg.id]

    storage_info {
      ebs_storage_info {
        volume_size = 1000
      }
    }
  }

  client_authentication {
    sasl {
      # SCRAM (Salted Challenge Response Authentication Mechanism) is an authentication protocol that is used to verify the identity of a client.
      scram = true
    }
  }
}


#  Amazon MSK requires that secrets be encrypted with a customer managed key, not an AWS managed key.
# The reason for this requirement is that customer managed keys offer more flexibility and control.
resource "aws_kms_key" "msk_kms_key" {
  description = "KMS key for MSK SCRAM secret"
  policy      = data.aws_iam_policy_document.kms_key_policy.json

  # Good practice to enable key rotation, but because it is a side project, I will leave it disabled
  # enable_key_rotation = true
}

# used to generate a JSON document that represents an IAM policy
data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root", "arn:aws:iam::${var.account_id}:user/${var.iam_user_name}"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_secretsmanager_secret" "scram_secret" {
  name       = var.scram_secret_name
  kms_key_id = aws_kms_key.msk_kms_key.key_id
}

resource "aws_secretsmanager_secret_version" "scram_secret" {
  secret_id     = aws_secretsmanager_secret.scram_secret.id
  secret_string = "{\"username\":\"${var.username}\",\"password\":\"${var.password}\"}"
}

resource "aws_msk_scram_secret_association" "scram_secret" {
  cluster_arn     = aws_msk_cluster.kafka_cluster.arn
  secret_arn_list = [aws_secretsmanager_secret.scram_secret.arn]
}
