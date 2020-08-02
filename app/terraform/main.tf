##
# This is only for demo purposes
##

resource "aws_s3_bucket" "public" {
  bucket = "protected-cloudfront-demo-app"
  acl    = "public-read"
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

data "aws_iam_policy_document" "public" {
  statement {
    sid     = "PublicReadForGetBucketObjects"
    actions = ["s3:GetObject"]
    effect  = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = ["${aws_s3_bucket.public.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.public.id
  policy = data.aws_iam_policy_document.public.json
}
