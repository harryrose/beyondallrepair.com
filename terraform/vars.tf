variable "zone" {
  default = "beyondallrepair.com"
}

variable "domains" {
  type = "list"
  default = ["beyondallrepair.com","www.beyondallrepair.com"]
}

variable "cert_domain" {
  default = "*.beyondallrepair.com"
}
variable "site_bucket" {
  default = "beyondallrepair.com"
}

variable "name_prefix" {
  default = "beyondallrepair_com_"
}