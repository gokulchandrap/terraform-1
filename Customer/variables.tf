variable "username" {
   description = "Softlayer user name"
}
variable "api_key" {
   description = "Softlayer API Key"
}
variable "prefix" {
   description = "Prepend hostnames with this"
   default     = "AAK"
}
variable "datacenter" {
   description = "This is the datacenter, Ours is Dallas 13"
   default     = "dal13"
}

variable "tags" {
   description = "This is the tags"
   default     = ["ctsp"]
}

variable "domain" {
  description = "I think this should always be ibm"
  default     = "ibm.com"
}

variable "hourly_billing" {
  description = "boolean"
  default     = true
}

variable "local_disk" {
  description = "boolean"
  default     = true
}

variable "memory" {
  description = "describe your variable"
  default     = 1024
}


variable "cores" {
  description = "describe your variable"
  default     = 1
}

variable "network_speed" {
  description = "describe your variable"
  default     = 1000
}

variable "os_reference_code_redhat" {
  description = "redhat 7 64bit OS"
  default     = "REDHAT_7_64"
}

variable "private_subnet" {
   description = "This is the subnet on customer side, everything should be on the same one"
   default     = "10.186.149.128/25"
}

