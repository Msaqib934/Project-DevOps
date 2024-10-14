resource "aws_s3_bucket" "backendpipeline" {
  bucket = "pipeline-backendbucket"
}

resource "aws_s3_bucket" "frontpipeline" {
  bucket = "pipeline-frontendbucket"
}
