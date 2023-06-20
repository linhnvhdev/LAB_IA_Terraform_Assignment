variable "ec2_password" {
  description = "Password in ec2 userdata"
  type = string
}

variable "kms_key_id" {
  description = "kms customer managed key id to encrypt"
  type = string
}