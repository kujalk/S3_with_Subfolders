#Will upload only the files with in the Source Folder to S3
variable UploadFolderContent{
    default ={
        "jana-temp006/temp/"=["E:\\Upwork","E:\\MyApp"]
    }
}

#Will upload whole folder to S3 - Only files are supported , Not any subfolders
variable UploadWholeFolder{
    default ={
        "jana-temp007/vehicle/"=["E:\\MyApp","E:\\MyApp\\cloudformation\\EC2_MySQL_Schema"]
    }
}

#Will upload only the specified files to S3
variable UploadOnlyFile{
    default ={
        "jana-temp007/vehicle/"=["E:\\sample2\\cool.txt","E:\\sample2\\tables\\person.csv"]
    }
}