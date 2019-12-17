variable "name" {
  description = "アプリケーションに使用する命名。"
  type        = string
}

variable "tags" {
  description = "各リソースに付与するtag"
  default     = {}
}

variable "acm_arn" {
  description = "ACMで発行したTLS証明書のARN"
  type        = string
}

variable "subnets" {
  description = "ALBを配置するサブネット一覧 e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']"
  type        = list
}

variable "security_groups" {
  description = "ALBに登録するセキュリティグループ一覧 e.g. ['sg-edcd9784','sg-edcd9785']"
  type        = list
}
