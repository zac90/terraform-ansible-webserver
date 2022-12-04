# Terraform provider details
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-2"
}

# Create security group to allow ports
resource "aws_security_group" "webserver" {
  name = "Webserver enabled ports"
  dynamic "ingress" {
    for_each = concat(var.sg_webserver_ingress, var.sg_ssh_ingress)
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_block
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  } 
}

# locals {
#   # Collate list of security group ids made
#   webserver_sg_ids = [aws_security_group.webserver.id]#, aws_security_group.webserver_ssh.id]
# }

# Create private key for instance connection
# Not the most secure way due to it storing key in terraform state
# But for this purpose it is okay.
resource "tls_private_key" "webserver" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create keypair from public cert generated above
resource "aws_key_pair" "webserver" {
  key_name   = var.webserver_pk_name     
  public_key = tls_private_key.webserver.public_key_openssh

# Write the private key to disk
  provisioner "local-exec" { 
    command = <<EOT
      echo '${tls_private_key.webserver.private_key_pem}' > ${var.local_pk_dir}/${var.webserver_pk_name} 
      chmod 600 ${var.local_pk_dir}/${var.webserver_pk_name}
      EOT
  }
}

resource "aws_instance" "webserver" {
  count                  = var.webserver_params.count
  ami                    = var.webserver_params.ami
  instance_type          = var.webserver_params.instance_type
  vpc_security_group_ids = [aws_security_group.webserver.id]
  key_name               = aws_key_pair.webserver.key_name
  root_block_device {
    volume_size = 8
  }
}

#Dynamically create Ansible inventory
resource "local_file" "ansible_inventory" {
    content = <<-EOT
      [webservers]
      %{ for ip in aws_instance.webserver.*.public_ip }${ip}%{ endfor }
      EOT
    filename = "${path.root}/../ansible/inventories/dev/hosts"
    file_permission = "0644"
}

# Created to ensure it always runs the latest Ansible
resource "null_resource" "ansible" {
  # Ensure this runs after generated IP
  triggers = {
    order = local_file.ansible_inventory.id
    always_run = "${timestamp()}"
  }
# Execute Ansible
  provisioner "local-exec" { 
    command = "sleep 10 && ansible-playbook -i inventories/dev/hosts site.yml --private-key ${var.local_pk_dir}/${var.webserver_pk_name}"
    working_dir = "${path.root}/../ansible"
    environment =  {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ANSIBLE_REMOTE_USER = var.webserver_params.ami_ssh_user
    }
  }
}

# output "webserver" {
#   value = "${path.root}/../"
#   #value = aws_instance.webserver[*].public_ip
# }

