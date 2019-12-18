output "vpc_id" {
  description = "VPCのID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "プライベートサブネットのID一覧"
  value       = module.vpc.private_subnets
}

output "alb_sg_id" {
  description = "ALBのセキュリティグループID"
  value       = module.sg_alb.sg_id
}

output "alb_https_listener_arn" {
  description = "ALB HTTPS ListenerのARN"
  value       = module.alb.https_listener_arn
}

output "ecs_cluster_name" {
  description = "ECSクラスター名"
  value       = aws_ecs_cluster.this.name
}
