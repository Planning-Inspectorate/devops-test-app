variable "name" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "value" {
  type    = string
  default = "<terraform_placeholder>"
}

variable "content_type" {
  type    = string
  default = "plaintext"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "ignore_value" {
  type    = bool
  default = true
}

variable "ignore_expiry" {
  type    = bool
  default = true
}

variable "prevent_destroy" {
  type    = bool
  default = false
}
