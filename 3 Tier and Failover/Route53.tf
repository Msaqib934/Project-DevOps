resource "aws_route53_health_check" "check1" {
  failure_threshold = 3
  fqdn             = aws_lb.application_load_balancer.dns_name # Replace with your fully qualified domain name
  port             = 80                     # The port to use for the health check
  request_interval = 30                     # Interval in seconds between consecutive health checks
  resource_path    = "/"                    # The path to the endpoint you want to check
  type             = "HTTP"                 # Type of health check (HTTP, HTTPS, TCP, etc.)
}

resource "aws_route53_health_check" "check2" {
  failure_threshold = 3
  fqdn             = aws_lb.application_load_balancer1.dns_name # Replace with your fully qualified domain name
  port             = 80                     # The port to use for the health check
  request_interval = 30                     # Interval in seconds between consecutive health checks
  resource_path    = "/"                    # The path to the endpoint you want to check
  type             = "HTTP"                 # Type of health check (HTTP, HTTPS, TCP, etc.)
}


# get hosted zone details
data "aws_route53_zone" "main" {
  name = "sherdilitacademy.net"
}

# create a record set in route 53
resource "aws_route53_record" "site_domain" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "saqib.sherdilitacademy.net"
  type    = "A"
  failover_routing_policy {
        type = "PRIMARY"
    }
  set_identifier  = "primary"
  health_check_id = aws_route53_health_check.check1.id

  alias {
    name                   = aws_lb.application_load_balancer.dns_name
    zone_id                = aws_lb.application_load_balancer.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "site_domain1" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "saqib.sherdilitacademy.net"
  type    = "A"
  failover_routing_policy {
        type = "SECONDARY"
    }
  set_identifier  = "secondary"
  health_check_id = aws_route53_health_check.check2.id
  
  alias {
    name                   = aws_lb.application_load_balancer1.dns_name
    zone_id                = aws_lb.application_load_balancer1.zone_id
    evaluate_target_health = false
  }
}