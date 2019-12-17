variable "name" {
  description = "リソースの識別子として使用する名前"
  type        = string
}

variable "description" {
  description = "作成するセキュリティグループに付与する説明"
  default     = ""
}

variable "tags" {
  description = "リソースに付与するタグ"
  default     = {}
}

variable "vpc_id" {
  description = "セキュリティグループを作成するVPCのID"
  type        = string
}

variable "ingress" {
  description = "許可するIngressの一覧（簡易版）。e.g. [{'cidr_blocks': '10.0.0.0/16', 'port': 80}, ...]"
  default     = []
}

variable "ingress_with_security_group_rules" {
  description = "許可するIngress（セキュリティグループベース）の一覧。 e.g. [{'source_security_group_id': 'sg-1a2b3c4d', 'from_port': 80, 'to_port': 80, 'protocol': 'tcp', 'description': ''}, ...]"
  default     = []
}
