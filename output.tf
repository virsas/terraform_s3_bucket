output "website_endpoint" {
  value = aws_s3_bucket.bucket.website_endpoint
}
output "name" {
  value = aws_s3_bucket.bucket.bucket
}
output "arn" {
  value = aws_s3_bucket.bucket.arn
}
output "id" {
  value = aws_s3_bucket.bucket.id
}
output "bucket_regional_domain_name" {
  value = aws_s3_bucket.bucket.bucket_regional_domain_name
}