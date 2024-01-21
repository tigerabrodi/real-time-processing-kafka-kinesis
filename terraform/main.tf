terraform {

  cloud {
    organization = "tiger_projects"
    workspaces {
      name = "streaming-kafka-kinesis"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

module "aws_msk" {
  source = "./modules/aws_msk"
}

module "firehose_key" {
  source     = "./modules/firehose_key"
  account_id = var.account_id
}

module "cloud_watch_logs" {
  source = "./modules/cloud_watch_logs"
}

module "kinesis_firehose" {
  source               = "./modules/firehose"
  cloud_watch_logs_arn = module.cloud_watch_logs.log_group_arn_firehose
  firehose_key_arn     = module.firehose_key.firehose_key_arn
  kafka_cluster_arn    = module.aws_msk.kafka_cluster_arn
  depends_on           = [module.aws_msk, module.cloud_watch_logs, module.firehose_key]
}

