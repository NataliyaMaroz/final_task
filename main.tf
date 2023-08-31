provider "aws" {
  # Specify the AWS profile and region for the provider
  profile = "default"
  region  = "eu-central-1"
}

# Generate a TLS private key
resource "tls_private_key" "nat_key" {
  algorithm = "RSA"
}

# Generate an AWS key pair using the TLS private key
resource "aws_key_pair" "generated_key" {
  key_name   = "nat_key"
  public_key = "${tls_private_key.nat_key.public_key_openssh}"

  # Ensure that this resource depends on the tls_private_key resource
  depends_on = [
    tls_private_key.nat_key
  ]
}

# Write the private key to a local file
resource "local_file" "key" {
  content       = "${tls_private_key.nat_key.private_key_pem}"
  filename      = "nat_key.pem"
  file_permission = "0400"

  # Ensure that this resource depends on the tls_private_key resource
  depends_on = [
    tls_private_key.nat_key
  ]
}

# Write the public key to a local file
resource "local_file" "public_key" {
  content  = aws_key_pair.generated_key.public_key
  filename = "nat_key.pub"

  # Ensure that this resource depends on the aws_key_pair resource
  depends_on = [aws_key_pair.generated_key]
}

# Create an AWS EC2 instance
resource "aws_instance" "nat_instance" {
  ami           = "ami-04e601abe3e1a910f"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.nat_sg.id]
  key_name      = aws_key_pair.generated_key.key_name

  # Add tags to the EC2 instance
  tags = {
    Name = "nat_instance"
  }
}

# Create an AWS security group to allow HTTP and SSH traffic
resource "aws_security_group" "nat_sg" {
  name        = "nat_sg"
  description = "Allow HTTP and SSH traffic via Terraform"

  # Allow incoming HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming SSH traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a null resource to create a hosts file with the public IP
resource "null_resource" "create_hosts_file" {
  triggers = {
    public_ip = aws_instance.nat_instance.public_ip
  }

  # Write the public IP to a hosts file
  provisioner "local-exec" {
    command = "echo '[nat_instance]' > hosts && echo '${aws_instance.nat_instance.public_ip}' >> hosts"
  }

  # Ensure that this resource depends on the aws_instance resource
  depends_on = [
    aws_instance.nat_instance
  ]
}

# Create another null resource to run Ansible playbook
resource "null_resource" "run_ansible" {
  triggers = {
    hosts_file_created = null_resource.create_hosts_file.id
  }

  # Run Ansible playbook with a delay of 30 seconds
  provisioner "local-exec" {
    command = "echo 'Start Ansible' && sleep 30 && ansible-playbook -i hosts nginx.yml"
    environment = {
      "ANSIBLE_HOST_KEY_CHECKING" = "False"
    }
    working_dir = path.module
  }

  # Ensure that this resource depends on the create_hosts_file resource
  depends_on = [
    null_resource.create_hosts_file
  ]
}