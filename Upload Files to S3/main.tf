/*
Developer - K.Janarthanan
Date - 2/12/2020
Purpose - Uploading Files/Directory to existing S3 Bucket
*/

locals {
  FolderContents = flatten([
    for BucketName, FolderPath in var.UploadFolderContent : [
      for Item in FolderPath : [
        for FileName in fileset(Item,"*") : {
            BucketPath = BucketName
            FilePath = format("%s\\%s", Item,FileName)
        }
    ]
    ]
  ])

  WholeFolders = flatten([
    for BucketName, FolderPath in var.UploadWholeFolder : [
      for Item in FolderPath : [
        for FileName in fileset(Item,"*") : {
            BucketPath = BucketName
            FilePath = format("%s\\%s", Item,FileName)
        }
    ]
    ]
  ])

    SpecificFiles = flatten([
    for BucketName, FilePath in var.UploadOnlyFile : [
      for Item in FilePath :  {
            BucketPath = BucketName
            FilePath = Item
        }
    ]
  ])

}

#This resource is used to upload all files recursively from the specified folder to S3
resource "aws_s3_bucket_object" "upload-folder-contents" {
    for_each = {
    for content in local.FolderContents : "${content.BucketPath}/${content.FilePath}" => content
}
    
    bucket = each.value.BucketPath
    key     =  replace(replace(each.value.FilePath, "\\", "-"),":","-")
    source = each.value.FilePath
    server_side_encryption = "AES256"
    etag = filemd5(each.value.FilePath)
}


#This resource is used to upload all Directory contents to S3 including with Directory (Subfolders are not supported)
resource "aws_s3_bucket_object" "upload-whole-folder" {
    for_each = {
    for content in local.WholeFolders : "${content.BucketPath}/${content.FilePath}" => content
}
    
    bucket = each.value.BucketPath
    key     = format("%s/%s",element(split("\\",dirname(each.value.FilePath)), length(split("\\",dirname(each.value.FilePath)))-1),basename(each.value.FilePath))
    source = each.value.FilePath
    server_side_encryption = "AES256"
    etag = filemd5(each.value.FilePath)
}


#This resource is used to upload only the specified file to S3
resource "aws_s3_bucket_object" "upload-only-file" {
    for_each = {
    for content in local.SpecificFiles : "${content.BucketPath}/${content.FilePath}" => content
}
    
    bucket = each.value.BucketPath
    key     =  replace(replace(each.value.FilePath, "\\", "-"),":","-")
    source = each.value.FilePath
    server_side_encryption = "AES256"
    etag = filemd5(each.value.FilePath)
}
