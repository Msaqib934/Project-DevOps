#data "kubectl_file_documents" "aws_provider" {
#  content = file("${path.module}/aws-secrets-manager.yaml") # Download YAML from AWS GitHub
#}

#resource "kubectl_manifest" "aws_provider" {
#  for_each  = data.kubectl_file_documents.aws_provider.manifests
#  yaml_body = each.value
#}
