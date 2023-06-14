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
  storage_encrypted          =  false 
  backup_retention_period    =  0 
  multi_az =  false 
  db_subnet_group_name = aws_db_subnet_group.default[0].name
  publicly_accessible = true
  count =  1 
}
