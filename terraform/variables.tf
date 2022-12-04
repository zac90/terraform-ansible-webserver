# Declare variables in this file and optionally assign default value.

# Local Private key location
variable "local_pk_dir" {
  type = string
}

variable "webserver_pk_name" {
  type = string
}

# Webserver vars
variable "webserver_params" {
  type = object({
    count         = number
    ami           = string
    instance_type = string
  })
}

# Use to assign SSH access
variable "sg_ssh_ingress" {
  type = list(object({
    cidr_block  = list(string)
    description = string
    port        = number
    protocol    = string
  }))
  default = [
    {
      cidr_block  = ["0.0.0.0/0"],
      description = "Some description of security group",
      port        = 22,
      protocol    = "tcp"
    }
  ]
}

# Used for other security group ingress
variable "sg_webserver_ingress" {
  type = list(object({
    cidr_block  = list(string)
    description = string
    port        = number
    protocol    = string
  }))
  default = [
    {
      cidr_block  = ["0.0.0.0/0"],
      description = "Some description of security group",
      port        = 8080,
      protocol    = "tcp"
    }
  ]
}