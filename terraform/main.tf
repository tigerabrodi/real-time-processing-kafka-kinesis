terraform {

  cloud {
    organization = "{your-organization}"
    workspaces {
      name = "{your-workspace}"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.33.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

module "aws_msk" {
  source            = "./modules/aws_msk"
  username          = var.scram_secret_username
  password          = var.scram_secret_password
  scram_secret_name = var.scram_secret_name
  account_id        = var.account_id
  iam_user_name     = var.iam_user_name
  ip_address        = var.ip_address
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
