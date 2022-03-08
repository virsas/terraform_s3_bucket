resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket.name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "access_block" {
  bucket = "${aws_s3_bucket.bucket.id}"

  block_public_acls       = var.blockPubAcl
  block_public_policy     = var.blockPubPol
  ignore_public_acls      = var.ignorePubAcl
  restrict_public_buckets = var.restrictPub

  depends_on = [aws_s3_bucket.bucket]
}

data "template_file" "policy" {
  template = file("json/s3/${var.bucket.name}.json")
  vars = {
    arn = "${aws_s3_bucket.bucket.arn}"
  }
}

resource "aws_s3_bucket_policy" "config_bucket_policy" {
  bucket = "${aws_s3_bucket.bucket.id}"
  policy = data.template_file.policy.rendered

  depends_on = [aws_s3_bucket.bucket]
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.bucket.versioning
  }

  depends_on = [aws_s3_bucket.bucket]
}

resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.bucket.id

  target_bucket = var.logbucket
  target_prefix = "s3/${var.bucket.name}/"

  depends_on = [aws_s3_bucket.bucket]
}

resource "aws_s3_bucket_lifecycle_configuration" "versioning-bucket-config" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id = "All"

    expiration {
      days = var.bucket.lifecycledays
    }

    status = var.bucket.lifecycle
  }

  epends_on = [aws_s3_bucket.bucket]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }

  depends_on = [aws_s3_bucket.bucket]
}