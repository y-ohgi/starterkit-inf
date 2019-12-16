variable "name" {
  description = "リソースの識別子として使用される名前"
  type        = string
}

variable "tags" {
  description = "リソースに付与するタグ"
  default     = {}
}

variable "azs" {
  description = "使用するアベイラビリティーゾーン"
  default     = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

variable "cidr" {
  description = "VPCで定義するCIDRブロック"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "作成するパブリックサブネットの一覧"
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "作成するプライベートサブネットの一覧"
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}
