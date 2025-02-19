variable "Profile" {
  description = "profile of aws (dev)"
  type        = string
}


variable "Region" {
  description = "region to deploy the resources"
  type        = string
}

variable "CIDR_Block" {
  description = "VPC CIDR_Block"
  type        = string
}

variable "VPC_name" {
  description = "VPC Tag name"
  type        = string
}

variable "subnet_count_public" {
  description = "Number of subnets"
  type        = string
}

variable "CIDRS_Public" {
  description = "Public CIDRS values"
  type = list(string)
}

variable "subnet_count_private" {
  description = "Number of subnets"
  type        = string
}

variable "CIDRS_Private" {
  description = "Private CIDRS Value"
  type        = list(string)
}

variable "CIDR_Public_Routes" {
  description = "Public CIDR Routes"
  type        = string
}

data "aws_availability_zones" "available" {
  state = "available"
}