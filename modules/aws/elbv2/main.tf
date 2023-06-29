/*

resource "aws_s3_bucket" "access_logging" {
  bucket_prefix = var.name
  acl    = "log-delivery-write"
  force_destroy = true

  versioning {
    enabled = true
  }

  count =  1 
}

*/

module "alb" {
  source  = "terraform-aws-modules/alb/aws"

  name = "main-app-alb"

  load_balancer_type = "application"

  internal = true

  enable_deletion_protection = false

  vpc_id             = var.vpc_id
  subnets            = [var.main_subnet_id,var.secondary_subnet_id]

  access_logs = {
    enabled = true
    prefix  = "khanhtq"
    bucket = var.logging_bucket
  }

  drop_invalid_header_fields = true

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = aws_iam_server_certificate.elb_main_cert[0].arn
      ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}


resource "aws_iam_server_certificate" "elb_main_cert" {
  name = "elb_main_cert"
  certificate_body = file(
    "${path.root}/static/example.crt.pem",
  )
  private_key = file(
    "${path.root}/static/example.key.pem",
  )

  count =  1 
}

/*

resource "aws_lb" "main" {
  load_balancer_type = "application"
  internal = true
  enable_deletion_protection = false
  subnets = ["${var.main_subnet_id}","${var.secondary_subnet_id}"]

  access_logs {
    bucket  = var.logging_bucket
    enabled = false
  }

  drop_invalid_header_fields = true
  count =  1 
}

resource "aws_lb_target_group" "main" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  count =  1 
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        =  "ELBSecurityPolicy-TLS-1-2-2017-01" 
  certificate_arn   = aws_iam_server_certificate.main_cert[0].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }

  count =  1 
}

resource "aws_kms_key" "access_logging_bucket_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "name" {
  bucket = aws_s3_bucket.access_logging[0].id
  rule {
    apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.access_logging_bucket_key.arn
        sse_algorithm     = "aws:kms"
    }
  }
  count =  1 
}

resource "aws_s3_bucket_public_access_block" "access_logging_bucket_public_access_block" {
  bucket = aws_s3_bucket.access_logging[0].id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
  count =  1 
}
*/