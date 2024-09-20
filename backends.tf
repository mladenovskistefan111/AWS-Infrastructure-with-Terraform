# --- root/backends.tf ---

# resource "aws_s3_bucket" "mybucket" {
#   bucket = "stefanremotestatefile"
#   lifecycle {
#     prevent_destroy = true
#   }
# }

# resource "aws_s3_bucket_versioning" "mybucket_versioning" {
#   bucket = aws_s3_bucket.mybucket.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "mybucket_sse" {
#   bucket = aws_s3_bucket.mybucket.id
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# resource "aws_dynamodb_table" "statelock" {
#   name         = "state-lock"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
#   lifecycle {
#     prevent_destroy = true
#   }
# }