variable "resource_location" {
  default     = "westus2"
  description = "Location of the resource group."
}

variable "environment" {
  default = "Terraform Demo"
  description = "Used for tagging"
}

variable "name" {
  default = "automationazuretf"
  description = "Used for tagging"
}
