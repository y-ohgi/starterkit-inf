variable "name" {
  description = "アプリケーションに使用する命名。"
  type        = string
}

variable "tags" {
  description = "各リソースに付与するtag"
  default     = {}
}

variable "domains" {
  description = "TLS証明書を発行するドメインの一覧"
  type        = list
}
