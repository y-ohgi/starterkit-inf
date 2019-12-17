output "sg_id" {
  description = "作成したセキュリティグループのID"
  value       = aws_security_group.this.id
}
