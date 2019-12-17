#########################
# Access Log Bucket
#########################
# S3 Bucketの命名は一意である必要があるため、S3のSuffixにランダムな値を付与する
resource "random_string" "s3_suffix" {
  special = false
  upper   = false
  length  = 8
}

locals {
  s3_bucket_name = "${var.name}-alb-log-${random_string.s3_suffix.result}"
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = local.s3_bucket_name

  force_destroy = true

  policy = <<EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::127311923021:root",
          "arn:aws:iam::033677994240:root",
          "arn:aws:iam::027434742980:root",
          "arn:aws:iam::797873946194:root",
          "arn:aws:iam::985666609251:root",
          "arn:aws:iam::156460612806:root",
          "arn:aws:iam::054676820928:root",
          "arn:aws:iam::652711504416:root",
          "arn:aws:iam::582318560864:root",
          "arn:aws:iam::600734575887:root",
          "arn:aws:iam::114774131450:root",
          "arn:aws:iam::783225319266:root",
          "arn:aws:iam::718504428378:root",
          "arn:aws:iam::507241528517:root"
        ]
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/*"
    }
  ]
}
EOL
}

#########################
# Application LoadBalancer
#########################
resource "aws_lb" "this" {
  security_groups = var.security_groups
  subnets         = var.subnets

  name = var.name
  tags = var.tags

  load_balancer_type = "application"

  access_logs {
    enabled = true
    bucket  = aws_s3_bucket.log_bucket.id
  }
}

#########################
# HTTP Listener
#########################
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.this.arn

  port     = "80"
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

#########################
# HTTPS Listener
#########################
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.this.arn
  certificate_arn   = var.acm_arn

  port     = "443"
  protocol = "HTTPS"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "ng"
      status_code  = "503"
    }
  }
}
