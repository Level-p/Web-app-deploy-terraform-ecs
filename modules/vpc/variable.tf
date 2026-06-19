variable "all_cidr" {
  description = "CIDR block for routing (e.g., 0.0.0.0/0)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Map of public subnets with CIDR and AZ"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    pub2 = { cidr = "10.0.2.0/24", az = "af-south-1b" }
    pub3 = { cidr = "10.0.3.0/24", az = "af-south-1c" }
  }
}

variable "private_subnets" {
  description = "Map of private subnets with CIDR and AZ"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    pri2 = { cidr = "10.0.5.0/24", az = "af-south-1b" }
    pri3 = { cidr = "10.0.6.0/24", az = "af-south-1c" }
  }
}

variable "name" {
  description = "Base name for resources"
  type        = string
}

variable "acm_certificate_arn" {}