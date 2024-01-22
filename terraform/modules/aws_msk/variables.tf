variable "username" {
  type      = string
  sensitive = true
}

variable "password" {
  type      = string
  sensitive = true
}

variable "scram_secret_name" {
  type      = string
  sensitive = true
}

variable "account_id" {
  type      = string
  sensitive = true
}

variable "iam_user_name" {
  type      = string
  sensitive = true
}

variable "ip_address" {
  type      = string
  sensitive = true

}
