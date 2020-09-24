variable "aws" {
  type = object({
    access_key = string,
    secret_key = string,
  region = string })
  description = "AWS Credentials"
}

variable "vpc_cidr" {
  type        = string
  default     = "192.168.0.0/16"
  description = "CIDR block for the VPC"
}
variable "public_sn_cidr" {
  type        = list(string)
  default     = ["192.168.1.0/24", "192.168.2.0/24"]
  description = "CIDR block for public subnet"
}

variable "auto_assign_pub_ip" {
type = bool 
default = true
description = "Auto Assign Public IP on public subnet"
}

variable "private_sn_cidr" {
  type        = list(string)
  default     = ["192.168.3.0/24", "192.168.4.0/24"]
  description = "CIDR block for private subnet"
}

variable "dest_cidr_block_public_route" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Public route to internet"

}

variable "dest_cidr_block_private_route" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Private route to NAT gateway"

}

variable "is_one_nat_gw" {
  type        = bool
  default     = true
  description = "Only Create One NAT on public subnet"
}


variable "instance_type" {
  default     = "t3.micro"
  type        = string
  description = "AWS Instance Size"
}

variable "image_id" {
  default     = "ami-093da183b859d5a4b"
  type        = string
  description = "AMI for Ubuntu 18.04"
}

variable "key_name" {
  default     = "prod"
  type        = string
  description = "SSH Pub Key"
}

variable "web_instance" {
type = bool 
default = true
description = "Only one instance on public subnet"
}