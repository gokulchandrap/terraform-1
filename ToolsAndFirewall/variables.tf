#variable "username" {
#   description = "Softlayer user name"
#}
#
#variable "api_key" {
#   description = "Softlayer API Key"
#}
variable "prefix" {
   description = "Hostname prefix <project>[<Enviroment Type>-]>[-<Account c Code>|<Spare Account Name>]"
   default     = "ctsp-d-aak1"
}

variable "sasg_ip_1" {
   description = "Private sasg customer ip address"
   default     = "10.186.149.141"
}

variable "sasg_vip_1" {
   description = "Softlayer Portable IP"
   default     = "10.186.95.5"
}

variable "bpm_hostname" {
   description = "BPM hostname"
   default     = "bpm"
}

variable "chef_hostname" {
   description = "Chef hostname"
   default     = "chef"
}

variable "ee_hostname" {
   description = "EE hostname"
   default     = "ee"
}

variable "fw_hostname" {
   description = "Firewall hostname"
   default     = "vyos1"
}

variable "fw_hostname_2" {
   description = "Firewall hostname"
   default     = "vyos2"
}

variable "datacenter" {
   description = "This is the datacenter, Ours is D.C. 07"
   default     = "wdc07"
}

variable "private_subnet" {
   description = "This is the subnet that was given to us, everything should be on the same one"
   default     = "10.190.87.128/26"
}

variable "tags" {
   description = "This is the tags"
   default     = ["ctsp"]
}

variable "fw_image_id" {
  description = "Firewall image ID: SASTeam_SasFW_Redhat_7.4_Image_V4"
  default     = "1764243"
}

variable "tools_image_id" {
  description = "Tools image ID: SLA_Default_Linux_Image"
  default     = "1775961"
}

variable "domain" {
  description = "I think this should always be ibm"
  default     = "ibm.com"
}

variable "private_key_path" {
  description = "Enter the path to your public key"
  default     = "/home/terraform/amazontestkey.pem"
}

#variable "public_key_path" {
#  description = "Enter the path to your public key \n For instance mine is: /Users/matthewxstaffelbach/.ssh/amazontestkey.pub"
#  default     = "/home/terraform/amazontestkey.pub"
#}

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

variable "disks" {
  description = "2 disks, one for image ID & and second is requried for booting"
  default     = [100,100]}

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

