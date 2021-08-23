variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}

variable "access_key" {
  description = "Value of the Access key for AWS"
  type        = string
}

variable "secret_key" {
  description = "Value of the Secret Key for AWS"
  type        = string
}
