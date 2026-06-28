
variable "AS_API_KEY" {
  type      = string
  sensitive = true
}

variable "MOVIE_API_KEY" {
  type      = string
  sensitive = true
}

variable "domain_name" {
  default = "mfon21.space"
  type = string
}
