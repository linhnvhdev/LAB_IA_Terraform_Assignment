resource "aws_ebs_volume" "main" {
  availability_zone = "ap-southeast-1a"
  size              = 1
  encrypted = true

  count =  1 
  kms_key_id = var.ebs_encrypt_key
}

resource "aws_ebs_encryption_by_default" "main" {
  enabled = false

  count =  1 
}

resource "aws_ebs_snapshot" "main_snapshot" {
  volume_id = aws_ebs_volume.main[0].id

  count =  1 
}
