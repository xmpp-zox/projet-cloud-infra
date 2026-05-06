output "alb_dns_name" {
  description = "Public DNS of the Application Load Balancer (frontend should call this)"
  value       = aws_lb.app.dns_name
}

output "frontend_url" {
  description = "Open this in a browser"
  value       = "http://${aws_instance.frontend.public_ip}"
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.address
}

output "vpc_id" {
  value = aws_vpc.main.id
}
