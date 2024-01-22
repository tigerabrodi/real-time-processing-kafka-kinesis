

output "scram_secret_name" {
  value     = module.aws_msk.scram_secret_name
  sensitive = true
}
