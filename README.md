# Overview
This repo quickly provisions a basic web server in AWS with Terraform and configures the server with Ansible

## Setup
1. Configure your AWS Access keys
2. Install Terraform and Ansible (Ensure Ansible has the community package of modules)
3. Clone the repo
4. Navigate to the repo directory then onto the terraform dir
5. Run a ```terraform init``` in the terraform dir
6. Run ```terraform apply```
7. A basic webserver should then be accessible at the public ip provided.