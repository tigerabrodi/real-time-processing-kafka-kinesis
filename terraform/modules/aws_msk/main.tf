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

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

resource "aws_msk_cluster" "kafka_cluster" {
  cluster_name           = "kafka-cluster"
  kafka_version          = "2.8.1"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type   = "kafka.t3.small"
    client_subnets  = tolist(data.aws_subnets.default.ids)
    security_groups = [data.aws_security_group.default.id]
    storage_info {
      ebs_storage_info {
        volume_size = 1000
      }
    }
  }
}
