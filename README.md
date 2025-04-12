# AWS Networking Infrastructure with Terraform (CSYE 6225)

This repository contains Terraform configurations to set up a complete AWS networking infrastructure including VPC, Subnets, Internet Gateway, and Route Tables.

## Prerequisites

1. AWS CLI installed and configured with appropriate credentials

   bash
   aws configure --profile dev

2. Install Terraform

## Usage

1. Clone the repository

   git clone <repository-url>
   cd tf-aws-infra

2. Initialize Terraform

   terraform init

3. Initialize Terraform

   terraform fmt -check -recursive

4. Review the plan

   terraform plan -var-file=terraform.tfvars

5. Apply the configuration

   terraform apply

6. To destroy the infrastructure

   terraform destroy

aws acm import-certificate \
--certificate fileb:///Users/kavya/SSL/demo_kavyamehta_me.crt\
--private-key fileb:///Users/kavya/SSL/mydomain.key \
--certificate-chain fileb:///Users/kavya/SSL/demo_kavyamehta_me.ca-bundle \
 --profile demo \
--region us-east-1
