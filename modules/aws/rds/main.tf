resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [var.main_subnet_id, var.secondary_subnet_id]
  count =  1 
}

resource "aws_db_instance" "main" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  db_name                 = var.name
  username             = "foo"
  password             = "foobarbaz"
  skip_final_snapshot = true

  auto_minor_version_upgrade =  false 
  storage_encrypted          =  true 
  backup_retention_period    =  7
  multi_az =  false 
  db_subnet_group_name = aws_db_subnet_group.default[0].name
  publicly_accessible = false
  count =  1 
  iam_database_authentication_enabled = true
  deletion_protection = true
  performance_insights_enabled = true
  performance_insights_kms_key_id = module.kms.performance_insights_kms_id
}

module "kms" {
  source = "../kms"
}
