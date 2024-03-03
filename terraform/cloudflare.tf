terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    curl2 = {
      source  = "mehulgohil/curl2"
      version = "1.6.1"
    }
  }
}

provider "curl2" {}

# We use this just to make a request to icanhazip.com
# to get our public IP address
data "curl2" "ip_request" {
  http_method = "GET"
  uri         = "http://icanhazip.com"
}

variable "cloudflare_api_key" {
  description = "The Cloudflare API key"
  type        = string
  sensitive   = true
}

variable "cloudflare_email" {
  description = "The Cloudflare email"
  type        = string
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

variable "cloudflare_zone_id" {
  description = "The Cloudflare zone ID"
  type        = string
  default     = "5160a6971536e107f477a6b4e6f08e86" 
}

resource "cloudflare_record" "glizzus_net" {
  name    = "glizzus.net"
  type    = "A"
  zone_id = var.cloudflare_zone_id
  comment = "Managed by Terraform, and OpenWRT dynamic DNS"
  value   = trim(data.curl2.ip_request.response.body, "\n")

  lifecycle {
    ignore_changes = [
      # We are going to ignore the changes to the IP address
      # since it is provisioned by dynamic DNS
      value,
    ]
  }
}

resource "cloudflare_record" "internal_glizzus_net" {
  name    = "*"
  type    = "A"
  zone_id = var.cloudflare_zone_id
  value   = "192.168.8.22"
}
