/*
Developer - K.Janarthana
Date - 1/12/2020
Purpose - To create S3 buckets with sub folders
*/

locals {
  BucketContents = flatten([
    for BucketName, BucketFolders in var.BucketStructure : [
      for Item in BucketFolders : {
        mainbucket = BucketName
        subfolder    = Item
      }
    ]
  ])
}


resource "aws_s3_bucket" "bucket" {
  for_each = var.BucketStructure
  bucket = each.key
  
  force_destroy = true

}

resource "aws_s3_bucket_policy" "bucketpolicy" {
  depends_on = [aws_s3_bucket.bucket]
  for_each = var.BucketStructure
  bucket = each.key

  policy = <<POLICY
{
  "Id": "S3 Secure Bucket Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": [
        "arn:aws:s3:::${each.key}",
        "arn:aws:s3:::${each.key}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      },
      "Principal": "*"
    },
    {
        "Sid": "DenyIncorrectEncryptionHeader",
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::${each.key}/*",
        "Condition": {
                "StringNotEquals": {
                        "s3:x-amz-server-side-encryption": "AES256"
                    }
        }
    },
    {
        "Sid": "DenyUnEncryptedObjectUploads",
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::${each.key}/*",
        "Condition": {
                "Null": {
                        "s3:x-amz-server-side-encryption": "true"
                }
        }   
    }
  ]
}
POLICY
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_s3_bucket_policy.bucketpolicy]
  create_duration = "30s"
}

resource "aws_s3_bucket_object" "folder_structure" {
    depends_on = [time_sleep.wait_30_seconds]
    for_each = {
    for bucket in local.BucketContents : "${bucket.mainbucket}/${bucket.subfolder}}" => bucket
}
    
    bucket = each.value.mainbucket
    acl     = "bucket-owner-full-control"
    key     =  each.value.subfolder
    content_type = "application/x-directory"
    server_side_encryption = "AES256"
}