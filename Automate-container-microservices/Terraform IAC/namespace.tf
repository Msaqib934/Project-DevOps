# Create a Cloud Map namespace
resource "aws_service_discovery_private_dns_namespace" "example" {
  name        = "myapp.local"
  description = "Private DNS namespace for service discovery"
  vpc         = aws_vpc.vpc-dev.id
}

# Create a Cloud Map service within the namespace
resource "aws_service_discovery_service" "example" {
  name = "backend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.example.id

    dns_records {
      type  = "A"
      ttl   = 60
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}