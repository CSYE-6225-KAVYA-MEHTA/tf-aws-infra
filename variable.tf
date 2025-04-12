variable "Profile" {
  description = "profile of aws (dev/demo)"
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
  type        = list(string)
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


variable "AMI" {
  description = "Machine image ID"
  type        = string
}

variable "INSTANCE_TYPE" {
  description = "Type of EC2 instance"
  type        = string
}

variable "VOLUME_SIZE" {
  description = "EBS volume size (in GB)"
  type        = number
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "cw_agent_role_name" {
  description = "The name of the IAM role for the CloudWatch Agent"
  type        = string
  default     = "CloudWatchAgentRole"
}

variable "cw_agent_policy_name" {
  description = "The name of the IAM policy for the CloudWatch Agent"
  type        = string
  default     = "CloudWatchAgentPolicy"
}

variable "cw_instance_profile_name" {
  description = "The name of the IAM instance profile for the CloudWatch Agent"
  type        = string
  default     = "CloudWatchAgentInstanceProfile"
}



variable "route53_zone_id" {
  description = "Route53 Zone ID for the domain"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application (e.g., dev.example.com)"
  type        = string
}

variable "asg_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 5
}

variable "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_cooldown" {
  description = "Cooldown period (in seconds) for the Auto Scaling Group"
  type        = number
  default     = 60
}


variable "Secrets_Name" {
  description = "Name of Secret"
  type        = string
}


variable "demo_certificate_arn" {
  description = "ARN for demo certificate"
  type        = string
}

variable "dev_certificate_arn" {
  description = "ARN for dev certificate"
  type        = string
}

# variable "acm_certificate_arn" {
#   description = "ARN of the SSL certificate to use for the HTTPS listener"
#   type        = string
# }