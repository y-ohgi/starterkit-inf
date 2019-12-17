output "alb_arn" {
  description = "作成したALBのARN"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "作成したALBのDNS"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "作成したALBのZoneId"
  value       = aws_lb.this.zone_id
}

output "http_listener_arn" {
  description = "作成したHTTP用ALB ListenerのARN"
  value       = aws_lb_listener.http_listener.arn
}

output "https_listener_arn" {
  description = "作成したHTTPS用ALB ListenerのARN"
  value       = aws_lb_listener.https_listener.arn
}
