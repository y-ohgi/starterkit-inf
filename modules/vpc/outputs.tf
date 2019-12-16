output "vpc_id" {
  description = "VPCのID"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "VPCのCIDRブロック"
  value       = aws_vpc.this.cidr_block
}

output "private_subnets" {
  description = "プライベートサブネットのIDの一覧"
  value       = aws_subnet.private.*.id
}

output "private_subnets_cidr_blocks" {
  description = "プライベートサブネットのCIDRの一覧"
  value       = aws_subnet.private.*.cidr_block
}

output "public_subnets" {
  description = "パブリックサブネットのIDの一覧"
  value       = aws_subnet.public.*.id
}

output "public_subnets_cidr_blocks" {
  description = "パブリックサブネットのCIDRの一覧"
  value       = aws_subnet.public.*.cidr_block
}
