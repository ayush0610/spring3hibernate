variable "AWS_REGION" {
  default = "us-east-1"
}

variable "key_name" {
  type        = string
  description = "The name for ssh key, used for aws_launch_configuration"
}