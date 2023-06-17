resource "aws_s3_bucket" "main" {
  bucket_prefix = var.name
  acl    = "private"
  force_destroy = true

  dynamic "server_side_encryption_configuration" {
    for_each =  [] 

    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }

  dynamic "logging" {
    for_each =  [] 

    content {
      target_bucket = aws_s3_bucket.logging[0].id
      target_prefix = var.name
    }
  }

  versioning {
      enabled =  true 
      mfa_delete = true
  }

  dynamic "website" {
    for_each =  [] 

    content {
      index_document = "index.html"
    }
  }
}

resource "aws_s3_bucket" "logging" {
  bucket_prefix = var.name
  acl    = var.bucket_acl
  force_destroy = true

  count =  0 
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
      aws_s3_bucket.main.arn,
      "${aws_s3_bucket.main.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "force_ssl_only_access" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.force_ssl_only_access.json

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
      aws_s3_bucket.getonly[0].arn,
      "${aws_s3_bucket.getonly[0].arn}/*",
    ]
  }

  count = 1
}

resource "aws_s3_bucket" "getonly" {
  bucket_prefix = "sadcloudhetonlys3"
  force_destroy = true
  count = 1
  versioning {
    mfa_delete = true
    enabled = true
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
      aws_s3_bucket.public[0].arn,
      "${aws_s3_bucket.public[0].arn}/*",
    ]
  }

  count = 1
}

resource "aws_s3_bucket" "public" {
  bucket_prefix = "sadcloudhetonlys3"
  force_destroy = true
  count = 1
  versioning {
    enabled = true
    mfa_delete = true
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  bucket = aws_s3_bucket.main.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

