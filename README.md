# final_task

Creating AWS EC2 Instance with Terraform and configuration with Ansible

This final project of ICP Bootcamp showss how I created an AWS EC2 instance  configured it using Ansible. It includes Terraform scripts to provision the EC2 instance, Ansible playbook to configure the instance, and outputs to display relevant information.

Resourses for this project:
  AWS account with appropriate permissions.
  Terraform installed on a local machine.
  Ansible installed on a local machine.
 
This project consists of the following components:
  main.tf: Terraform configuration file to provision an EC2 instance, key pair generation and security group.
  outputs.tf Terraform file to provision useful information about output of main.tf configuration.
  nginx.yml: Ansible playbook to configure the EC2 instance with Nginx.
  README.md: Project documentation.

Usage
  Commands <terraform init> and <terraform apply> check .tf files comfigurations and run the proccesses of creating EC2 instanse and it's components, such as key pair, security group, ansible playboock whixh updates EC2 OS and installes web server Nginx (. 

  Outputs
After successfully provisioning and configuring the EC2 instance, there is an useful information provided by outputs.tf:
  EC2 Instance ID.
  Public IP address of the EC2 instance.
  Key pair ID used for SSH access.
  Security group ID associated with the instance.

