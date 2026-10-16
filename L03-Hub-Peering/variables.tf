variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "allow_gateway_transit" {
  type    = bool
  default = false
}

variable "peering_name_forward" {
  type = string
}

variable "peering_name_reverse" {
  type = string
}

variable "remote_vnet_id_forward" {
  type = string
}

variable "remote_vnet_id_reverse" {
  type = string
}

variable "rg_name_forward" {
  type = string
}

variable "rg_name_reverse" {
  type = string
}

variable "vnet_name_forward" {
  type = string
}

variable "vnet_name_reverse" {
  type = string
}

