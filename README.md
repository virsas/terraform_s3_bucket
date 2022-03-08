# tfmod_s3_bucket

Terraform module to create private and encrypted S3 bucket.

## Terraform example

``` terraform
variable "website_bucket" {
  default = {
    # name of the bucket
    name = "website"
    # Enable or disable versioning of files. If enabled, files are not deleted or updated. Instead, just replaced, and old ones are flagged as older versions.
    versionion = false
    # Enable or disable cleanup of the folder. Not good for a website, but good for the logs bucket.
    lifecycle = false
    # How long to keep the files in the bucket if lifecycle is enabled
    lifecycledays = 365
    # Type of encryption
    encrypt_algo = "AES256"
  }
}

module "s3_website" {
  source    = "github.com/virsas/tfmod_s3_bucket"
  bucket    = var.website_bucket
  # the name of the logging bucket. It can be var.s3_bucket.name if it is a logging bucket itself or module.s3_bucket.id if it is any other bucket, expect the logging one.
  logbucket = module.s3_logs.bucket
  // Optional variables (default value: true)
  // block public access
  blockPubAcl = true
  // block public policies
  blockPubPol = true
  // ignore public acl
  ignorePubAcl = true
  // restrict public access
  restrictPub = true
}
```

## Policy

this module need a json policy too. The policy should be located in ./json/s3/ directory with name of the bucket.

``` bash
mkdir -p ./json/s3
touch ./json/s3/website.json
nano ./json/s3/website.json
```

and you can add anything you want. For example, limit non ssl access to this bucket and allow access only from cloud front origin ID.

``` JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Allow CF access to bucket",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity XYZXYZXYZXYZXYZ"
      },
      "Action": "s3:GetObject",
      "Resource": "${arn}/*"
    },
    {
      "Sid": "Require SSL",
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:*",
      "Resource": "${arn}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
```
