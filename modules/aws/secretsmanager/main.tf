resource "aws_secretsmanager_secret" "ec2_secret" {
  name = "ec2_secret"
  description = "To store password in user data in ec2"
}

resource "aws_secretsmanager_secret_version" "service_user" {
  secret_id     = aws_secretsmanager_secret.ec2_secret
  secret_string = var.ec2_password
}