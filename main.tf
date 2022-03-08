resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket.name

  versioning {
    enabled = var.bucket.versioning
  }

  lifecycle {
    prevent_destroy = true
  }

  lifecycle_rule {
    enabled = var.bucket.lifecycle

    expiration {
      days = var.bucket.lifecycledays
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.bucket.encrypt_algo
      }
    }
  }

  logging {
    target_bucket = var.logbucket
    target_prefix = "s3/${var.bucket.name}/"
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
