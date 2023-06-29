data "aws_caller_identity" "current" {}

module "main" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "3.14.0"
  bucket = var.name
  acl = "private"
  force_destroy = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.s3_kms_key_id
      }
    }
  }
  versioning = {
    enabled = true
  }

  logging = {
    target_bucket = module.logging.s3_bucket_id
    target_prefix = var.name
  }
  website = {
    index_document = "index.html"
  }
}

module "logging" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "3.14.0"
  bucket = "logging-bucket-1wfq1h3xyz"
  acl    = "log-delivery-write"
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.s3_kms_key_id
      }
    }
  }
  versioning = {
    enabled = true
  }
  attach_access_log_delivery_policy = true
}



data "aws_iam_policy_document" "force_ssl_only_access" {
  # Force SSL access
  statement {
    sid = "ForceSSLOnlyAccess"

    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      module.main.s3_bucket_arn,
      "${module.main.s3_bucket_arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

data "aws_iam_policy_document" "receive_logs" {
  statement {
    sid = "S3ServerAccessLogsPolicy"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      module.logging.s3_bucket_arn,
      "${module.logging.s3_bucket_arn}/*"
    ]
  }
}


resource "aws_s3_bucket_policy" "force_ssl_only_access" {
  bucket = module.main.s3_bucket_id
  policy = data.aws_iam_policy_document.force_ssl_only_access.json

  count = 1
}

resource "aws_s3_bucket_policy" "receive_logs" {
  bucket = module.logging.s3_bucket_id
  policy = data.aws_iam_policy_document.receive_logs.json

  count = 1
}

data "aws_iam_policy_document" "getonly" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:GetObject"]

    resources = [
      module.getonly.s3_bucket_arn,
      "${module.getonly.s3_bucket_arn}/*",
    ]
  }

  count = 1
}

module "getonly" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "3.14.0"
  bucket = "sascloud-getonly-s3"
  acl = "private"
  force_destroy = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.s3_kms_key_id
      }
    }
  }
  versioning = {
    enabled = true
  }

  logging = {
    target_bucket = module.logging.s3_bucket_id
    target_prefix = "sascloud-getonly-1wfq1h3"
  }
}

data "aws_iam_policy_document" "public" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      module.public.s3_bucket_arn,
      "${module.public.s3_bucket_arn}/*",
    ]
  }

  count = 1
}

module "public" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "3.14.0"
  bucket = "sascloud-public-s3"
  acl = "private"
  force_destroy = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.s3_kms_key_id
      }
    }
  }
  versioning = {
    enabled = true
  }

  logging = {
    target_bucket = module.logging.s3_bucket_id
    target_prefix = "sascloud-public-1wfq1h3"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block_main" {
  bucket                  = module.main.s3_bucket_id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block_getonly" {
  bucket                  = module.getonly.s3_bucket_id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block_public" {
  bucket                  = module.public.s3_bucket_id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block_logging" {
  bucket                  = module.logging.s3_bucket_id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "elbv2_receive_logs" {
  # Force SSL access
  statement {
    sid = "S3ServerAccessLogsPolicy"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      module.elbv2_logging.s3_bucket_arn,
      "${module.elbv2_logging.s3_bucket_arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "elbv2_receive_logs" {
  bucket = module.elbv2_logging.s3_bucket_id
  policy = data.aws_iam_policy_document.elbv2_receive_logs.json
  count = 1
}

module "elbv2_logging" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "3.14.0"
  bucket = "logging-bucket-elbv2-logging-khanhtq"
  acl    = "log-delivery-write"
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.s3_kms_key_id
      }
    }
  }
  versioning = {
    enabled = true
  }
  attach_elb_log_delivery_policy = true
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block_elbv2_logging" {
  bucket                  = module.elbv2_logging.s3_bucket_id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}





