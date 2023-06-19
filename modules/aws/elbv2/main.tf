resource "aws_s3_bucket" "access_logging" {
  bucket_prefix = var.name
  acl    = "private"
  force_destroy = true

  logging {
    target_bucket = aws_s3_bucket.logging[0].id
    target_prefix = var.name
  }

  versioning {
    enabled = true
  }

  count =  1 
}

resource "aws_lb" "main" {
  load_balancer_type = "application"
  internal = true
  enable_deletion_protection = false
  subnets = ["${var.main_subnet_id}","${var.secondary_subnet_id}"]

  access_logs {
    bucket  = aws_s3_bucket.access_logging[0].bucket_prefix
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

resource "aws_iam_server_certificate" "main" {
  name = "test_cert"
  certificate_body = file(
    "${path.root}/static/example.crt.pem",
  )
  private_key = file(
    "${path.root}/static/example.key.pem",
  )

  count =  1 
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        =  "ELBSecurityPolicy-TLS-1-2-2017-01" 
  certificate_arn   = aws_iam_server_certificate.main[0].arn

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
  bucket = aws_s3_bucket.access_logging.id
  rule {
    apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.access_logging_bucket_key.arn
        sse_algorithm     = "aws:kms"
    }
  }
  count =  1 
}

resource "aws_s3_bucket_public_access_block" "access_logging_bucket_public_access_block" {
  bucket = aws_s3_bucket.access_logging.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
  count =  1 
}