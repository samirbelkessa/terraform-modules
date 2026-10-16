variable "Brainboard_IP_Range_List" {
  type    = list(string)
  default = ["3.18.12.57", "3.19.117.9", "3.12.21.31", "3.140.65.244", "18.223.219.168", "3.139.254.14", "3.109.176.247", "13.235.196.228", "3.108.102.235", "35.154.77.165", "159.196.14.175/32"]
}

variable "bastion_subnet_id" {
  description = "Resource ID of the AzureBastionSubnet to associate the NSG with. Required when create_association is true."
  type        = string
  default     = ""
}

variable "create_association" {
  description = "Whether to create the NSG-to-subnet association. Set to false when NSG is passed to AVM module via custom subnet."
  type        = bool
  default     = true
}

variable "location" {
  description = "Azure region for the NSG."
  type        = string
}

variable "nsg_name" {
  description = "Name of the NSG for AzureBastionSubnet."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name where the NSG will be created."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the NSG."
  type        = map(string)
  default     = {}
}

