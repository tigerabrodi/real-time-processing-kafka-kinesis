variable "account_id" {
  type      = string
  sensitive = true
}

variable "iam_user_name" {
  type      = string
  sensitive = true
}

variable "scram_secret_username" {
  type      = string
  sensitive = true
}

variable "scram_secret_password" {
  type      = string
  sensitive = true
}

variable "scram_secret_name" {
  type      = string
  sensitive = true
}

variable "ip_address" {
  type      = string
  sensitive = true

}
