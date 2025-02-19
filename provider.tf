# Configure the AWS Provider
provider "aws" {
  profile = var.Profile
  region = var.Region
}