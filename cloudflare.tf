terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "zone_id" {
  description = "Cloudflare zone ID"
  type        = string
}

variable "domain" {
  description = "Domain name"
  type        = string
}

resource "cloudflare_record" "this" {
  zone_id = var.zone_id
  name    = var.domain
  value   = var.origin_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

variable "origin_ip" {
  description = "Origin server IP"
  type        = string
}
