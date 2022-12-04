# Assign values to variables declared in variables.tf here
webserver_params = {
  ami           = "ami-0df609f69029c9bdb",
  count         = 1,
  instance_type = "t2.micro"
}

local_pk_dir = "~/.ssh"
webserver_pk_name = "aws_webserver"

sg_ssh_ingress = [
  {
    cidr_block  = ["0.0.0.0/0"],
    description = "SSH traffic from specific host",
    port        = 22,
    protocol    = "tcp"
  }
]

sg_webserver_ingress = [
  {
    cidr_block  = ["0.0.0.0/0"],
    description = "HTTP Web Traffic from internet",
    port        = 80,
    protocol    = "tcp"
  },
  {
    cidr_block  = ["0.0.0.0/0"],
    description = "HTTPS Web Traffic from internet",
    port        = 443,
    protocol    = "tcp",
  }
]