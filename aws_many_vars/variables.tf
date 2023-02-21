variable "access_key" {
  description = "Value of the Access key for AWS"
  type        = string
}

variable "secret_key" {
  description = "Value of the Secret Key for AWS"
  type        = string
}

variable "profile" {
    description = "Provider Profile"
    type        = string
    default     = "DevTest"
}

variable "region" {
    description = "AWS Region"
    type        = string
    default     = "us-west-2"
}

variable "ami" {
    description = "AWS AMI Name"
    type        = string
    default     = "ami-08d70e59c07c61a3a"
}

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "AutomationAwsTerraform"
}

variable "instance_type" {
    description = "AWS Instance Type"
    type        = string
    default     = "t1.micro"
}
